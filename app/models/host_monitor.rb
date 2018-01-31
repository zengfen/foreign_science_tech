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

	def self.get_es_index(time)
		index_name = "hosts_datas_#{Date.parse(time).strftime('%Y%m')}"
    return index_name
	end

  def self.create_index(time_is)
  	#{"CPU"=>[{"count"=>1}], "Disk"=>[{"free"=>30114562048, "path"=>"/", "total"=>42139451392, "used"=>9860739072, "used_percent"=>23.400254977861483}], "Load"=>[{"load1"=>0}, {"load5"=>0.03}, {"load15"=>0}], "Memory"=>[{"cached"=>761057280, "free"=>852967424, "total"=>2097446912, "used"=>388317184, "used_percent"=>18.513802746488775}], "ts"=>"1517225350"} 
    es_index_name = get_es_index(Time.at(time_is.to_i).to_s)
    if !($elastic.indices.exists? index: "#{es_index_name}")
      $elastic.indices.create index: "#{es_index_name}", body: {
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
              path:{type: 'keyword',index:'not_analyzed'},
              network_environment:{type: 'integer',index:'not_analyzed'}, #国内外
              cpu_count:{type: 'integer',index:'not_analyzed'}, #CPU 核数
              load1:{type: 'scaled_float',index:'not_analyzed',scaling_factor:100},#1分钟内负载
              load5:{type: 'scaled_float',index:'not_analyzed',scaling_factor:100},#5分钟内负载
              load15:{type: 'scaled_float',index:'not_analyzed',scaling_factor:100},#15分钟内负载
              disk_free:{type: 'long',index:'not_analyzed'}, #磁盘剩余
              disk_total:{type: 'long',index:'not_analyzed'}, #磁盘总量
              disk_used:{type: 'long',index:'not_analyzed'}, #磁盘已使用
              disk_used_percent:{type: 'scaled_float',index:'not_analyzed',scaling_factor:100}, #磁盘使用比
              memory_cached:{type: 'long',index:'not_analyzed'},
              memory_free:{type: 'long',index:'not_analyzed'},
              memory_total:{type: 'long',index:'not_analyzed'},
              memory_used:{type: 'long',index:'not_analyzed'},
              memory_used_percent:{type: 'scaled_float',index:'not_analyzed',scaling_factor:100},
              ts:{type: 'integer',index:'not_analyzed'},
              recording_time:{type: 'date', index:'not_analyzed'}
            }
          }
        }
      }
    end
  end

end
