# == Schema Information
#
# Table name: host_monitors
#
#  id                  :integer          not null, primary key
#  extranet_ip         :inet
#  intranet_ip         :inet
#  network_environment :integer          default(1)
#  host_status         :integer          default(0)
#  process_status      :integer          default(0)
#  recording_time      :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  machine_info        :json
#  host_id             :integer
#

class HostMonitor < ApplicationRecord
  before_create :init_network_environment!

  belongs_to :host

	
	def init_network_environment!
		return if extranet_ip.blank?		
		c = $geo_ip.country(extranet_ip.to_s)
    self.network_environment = c.country_code2 == 'CN' ? 1 : 2
	end

	def self.network_environments
    { '境内' => 1, '境外' => 2 }
  end

  def network_environment_cn
    self.class.network_environments.invert[network_environment]
  end

	def self.es_index_name
		"hosts_datas_*"
	end

	def self.get_es_index(time)
		index_name = "hosts_datas_#{Date.parse(time).strftime('%Y%m')}"
    return index_name
	end

  def self.create_index(es_index_name)
  	#{"CPU"=>[{"count"=>1}], "Disk"=>[{"free"=>30114562048, "path"=>"/", "total"=>42139451392, "used"=>9860739072, "used_percent"=>23.400254977861483}], "Load"=>[{"load1"=>0}, {"load5"=>0.03}, {"load15"=>0}], "Memory"=>[{"cached"=>761057280, "free"=>852967424, "total"=>2097446912, "used"=>388317184, "used_percent"=>18.513802746488775}], "ts"=>"1517225350"} 
    $elastic = EsConnect.new
    if !($elastic.indices.exists? index: es_index_name)
      $elastic.indices.create index: es_index_name, body: {
        settings: {
            index: {
            number_of_shards: 10,
            number_of_replicas: 1
          }
        },
        mappings: {
          new_network_data: {
            _all: {
              analyzer: "ik_max_word",
              search_analyzer: "ik_max_word",
            },
            properties: {
              extranet_ip:{type: 'keyword',index:'not_analyzed'}, #外网IP
              intranet_ip:{type: 'keyword',index:'not_analyzed'}, #内网IP
              network_environment:{type: 'integer',index:'not_analyzed'}, #国内外
              network_environment_cn:{type: 'keyword',index:'not_analyzed'}, #国内外中文
              ts:{type: 'integer',index:'not_analyzed'},
              recording_time:{type: 'date', index:'not_analyzed'},
              cpu_count:{type: 'integer',index:'not_analyzed'}, #CPU 核数
              disks:{
                type: 'nested',
                properties:{
                  total:{type: 'long',index:'not_analyzed'},
                  free:{type: 'long',index:'not_analyzed'},
                  used:{type: 'long',index:'not_analyzed'}, #磁盘已使用
                  used_percent:{type: 'scaled_float',index:'not_analyzed',scaling_factor:100},
                  path:{type: 'keyword',index:'not_analyzed'}
                }
              },
              load1:{type: 'scaled_float',index:'not_analyzed',scaling_factor:100},#1分钟内负载
              load5:{type: 'scaled_float',index:'not_analyzed',scaling_factor:100},#5分钟内负载
              load15:{type: 'scaled_float',index:'not_analyzed',scaling_factor:100},#15分钟内负载
              memory_cached:{type: 'long',index:'not_analyzed'},
              memory_free:{type: 'long',index:'not_analyzed'},
              memory_total:{type: 'long',index:'not_analyzed'},
              memory_used:{type: 'long',index:'not_analyzed'},
              memory_used_percent:{type: 'scaled_float',index:'not_analyzed',scaling_factor:100}
            }
          }
        }
      }
    end
  end

  def batch_create_index(start_time,end_time)
  	indices = Date.parse(start_time.to_s)..Date.parse(end_time.to_s).collect{|x|  "hosts_datas_#{x.strftime('%Y%m')}"}.uniq
  	indices.collect{|x| create_index(x)} unless indices.blank?
  end

  def self.load_data_to_es
    $elastic = EsConnect.new
  	start_record = find_latest_sync_record || HostMonitor.order("id asc").first
  	
  	return if start_record.blank?

  	end_record = HostMonitor.order("id desc").first

    start_time = start_record.recording_time
    end_time =  end_record.recording_time
    batch_create_index(start_time,end_time)

  	HostMonitor.where("id > ? and id <= ? ",start_id,end_id).order("id asc").find_in_batches do |datas|

      body = []
      datas.each do |r|
        #{"CPU"=>[{"count"=>1}], "Disk"=>[{"free"=>30114562048, "path"=>"/", "total"=>42139451392, "used"=>9860739072, "used_percent"=>23.400254977861483}], "Load"=>[{"load1"=>0}, {"load5"=>0.03}, {"load15"=>0}], "Memory"=>[{"cached"=>761057280, "free"=>852967424, "total"=>2097446912, "used"=>388317184, "used_percent"=>18.513802746488775}], "ts"=>"1517225350"} 
        machine_info = r.machine_info 
        next if machine_info.blank?
  	  	begin
          ts = machine_info["ts"].to_i  rescue ""
          disks = machine_info["Disk"] rescue []

          cpu_count = machine_info["CPU"].map{|x| x.fetch("count") if x.has_key?"count"}.compact.first rescue ""
          load1 = machine_info["Load"].map{|x| x.fetch("load1") if x.has_key?"load1"}.compact.first rescue ""
          load5 = machine_info["Load"].map{|x| x.fetch("load5") if x.has_key?"load5"}.compact.first rescue ""
          load15 = machine_info["Load"].map{|x| x.fetch("load15") if x.has_key?"load15"}.compact.first rescue ""

          memory_cached = machine_info["Memory"].first.fetch("cached") rescue ""
          memory_free = machine_info["Memory"].first.fetch("free") rescue ""
          memory_total = machine_info["Memory"].first.fetch("total") rescue ""
          memory_used = machine_info["Memory"].first.fetch("used") rescue ""
          memory_used_percent = machine_info["Memory"].first.fetch("used_percent") rescue ""

  	  	  tmp = { index: { _index:"#{get_es_index(recording_time)}", _type: "#{get_es_index(recording_time)}", _id: r.id, data: {
  	              extranet_ip:r.extranet_ip.to_s, #外网IP
  	              intranet_ip:r.intranet_ip.to_s, #内网IP
  	              network_environment:r.network_environment, #国内外
  	              network_environment_cn:r.network_environment_cn,#国内外中文
                  ts:ts,
                  recording_time:r.recording_time,
  	              cpu_count:cpu_count, #CPU 核数
                  disks: disks,
  	              load1:load1,#1分钟内负载
  	              load5:load5,#5分钟内负载
  	              load15:load15,#15分钟内负载
  	              memory_cached:memory_cached,
  	              memory_free:memory_free,
  	              memory_total:memory_total,
  	              memory_used:memory_used,
  	              memory_used_percent:memory_used_percent
  	        } } }
  	      body << tmp
  	    rescue Exception => e
  	      puts e
  	      puts r.inspect
  	      break
  	    end
      end
	    return nil if body.blank?
	    begin
	      $elastic.bulk body: body
	    rescue
	      retry
	    end   
    end
  end

  def self.find_latest_sync_record
     $elastic = EsConnect.new
     index = HostMonitor.es_index_name
     res = $elastic.search index: index, body:{query:{},size:1,from:0,sort:[{_id:{order:'asc'}}]}
     id = res["hits"]["hits"].first["_source"]["id"] rescue nil
     record  = HostMonitor.find_by(:id=>id)
     return record
  end

end
