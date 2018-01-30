# == Schema Information
#
# Table name: hosts
#
#  id                  :integer          not null, primary key
#  extranet_ip         :inet
#  intranet_ip         :inet
#  network_environment :integer          default("1")
#  host_status         :integer          default("0")
#  process_status      :integer          default("0")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  host_service_info   :json
#  host_service        :string           is an Array
#  machine_info        :json
#  recording_time      :datetime
#

class Host < ApplicationRecord
  VALID_IP_REGEX = /\A(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\z/
  validates :extranet_ip, format: { with: VALID_IP_REGEX }


	has_many :host_monitors,dependent: :destroy
  before_create :init_network_environment!

  scope :service,->(service) {where("'#{service.to_s}' = ANY (host_service)")}
  #Host.service(:agent)
  scope :multi_services,->(services) {where("host_service @> ARRAY[?]::varchar[]", services)}#Host.multi_services(["agent","supervisor"])
 
	## Hosts with 3 or more services
	# Host.where("array_length(host_service, 1) >= 3")

  def init_network_environment!
    return if extranet_ip.blank?
    c = $geo_ip.country(extranet_ip.to_s)
    self.network_environment = c.country_code2 == 'CN' ? 1 : 2
  end

  def self.network_environments
    { '境内' => 1, '境外' => 2 }
  end

  def network_environment_cn
    Host.network_environments.invert[network_environment]
  end

  def self.get_status(heartbeat_at, status)
    return '未知' if (Time.now.to_i - heartbeat_at) > 60 && status == 'true'

    status == 'true' ? '运行中' : '已停止'
  end

  def self.services
    {
      'agent' => '爬虫节点',
      'supervisor' => '节点监控器',
      'controller' => '主机控制器',
      'dispatcher' => '任务分发器',
      'loader' => '数据loaders',
      'receiver' => '数据接收器'
    }
  end

  def self.get_service_name(service)
    services[service]
  end

  def self.load_host_datas
  	hosts_hash = $archon_redis.hgetall('archon_hosts')
  	return if hosts_hash.blank?
  	
  	hosts_hash.each do |k,v|
  		h = Host.where(:extranet_ip=>k).first
  		h = Host.new(:extranet_ip=>k) if h.blank?
  		if h.recording_time.blank? || h.recording_time < Time.at(v.to_i)

  			#更新服务器用途
        host_services_hash = $archon_redis.hgetall("archon_host_services_#{k}") 
        host_services = host_services_hash.keys
        h.update_attributes(:host_service_info=> host_services_hash, :host_service=>host_services)

        data = $archon_redis.lindex("archon_host_metrics_#{k}",-1)
        next if data.blank?
        data = JSON.parse(data) 

        while v.to_i >= data["ts"].to_i
          
          #更新host最新信息  
          h.update_attributes(:machine_info=> data, :recording_time=>Time.at(data["ts"].to_i))  

	        #记录流水
	        hm = HostMonitor.create(:extranet_ip=>k,:machine_info=>data,:recording_time=> Time.at(data["ts"].to_i),:host_id=>h.id)
	        
	        #Rpop 数据
	        $archon_redis.rpop("archon_host_metrics_#{k}") 

	        data = $archon_redis.lindex("archon_host_metrics_#{k}",-1)
	        break if data.blank?
          data = JSON.parse(data) 
        end
        
  		end
  	end
  end

end
