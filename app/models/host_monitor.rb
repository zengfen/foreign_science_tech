# == Schema Information
#
# Table name: host_monitors
#
#  id                  :integer          not null, primary key
#  extranet_ip         :inet
#  intranet_ip         :inet
#  network_environment :integer          default(1)
#  cpu                 :string
#  memory              :string
#  disk                :string
#  host_status         :integer          default(0)
#  process_status      :integer          default(0)
#  recording_time      :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class HostMonitor < ApplicationRecord
  before_create :init_network_environment!

	
	def init_network_environment!
		return if extranet_ip.blank?		
		c = $geo_ip.country(extranet_ip.to_s)
    self.network_environment = c.country_code2 == 'CN' ? 1 : 2
	end

	def self.load_host_datas
  	hosts_hash = $archon_redis.hgetall('archon_hosts')
  	next if hosts_hash.blank?
  	
  	hosts_hash.each do |k,v|
  		h = Host.where(:extranet_ip=>k).first
  		h = Host.new(:extranet_ip=>k) if h.blank?
  		if h.recording_time.blank? || h.recording_time < Time.at(v)
        #Rpop
        data = $archon_redis.lindex("archon_host_metrics_#{k}",-1)
        next if data.blank?
        data = JSON.parse(data) 

        while v >= data["ts"].to_i
          #更新host最新信息    
	        h.machine_info = data.to_json
	        h.recording_time = Time.at(data["ts"].to_i)
	        h.save

	        #记录流水
	        hm = HostMonitor.create(:extranet_ip=>k,:machine_info=>data.to_json,:recording_time=> Time.at(data["ts"].to_i))
	        #Rpop 数据
	        $archon_redis.rpop("archon_host_metrics_#{k}",data.to_json) 

	        data = $archon_redis.lindex("archon_host_metrics_#{k}",-1)
	        break if data.blank?
          data = JSON.parse(data) 
        end
        
  		end
  	end
  end
end
