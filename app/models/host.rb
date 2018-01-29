# == Schema Information
#
# Table name: hosts
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
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Host < ApplicationRecord
	VALID_IP_REGEX = /\A(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\z/
  validates :extranet_ip,format: { with: VALID_IP_REGEX }

  before_create :init_network_environment!

	
	def init_network_environment!
		return if extranet_ip.blank?		
		c = $geo_ip.country(extranet_ip.to_s)
    self.network_environment = c.country_code2 == 'CN' ? 1 : 2
	end

	def self.network_environments
		{"境内"=>1, "境外"=>2}
	end

	def network_environment_cn
		Host.network_environments.invert[self.network_environment]
	end


  def self.get_status(heartbeat_at, status)
    if (Time.now.to_i - heartbeat_at) > 60 && status == "true"
      return "未知"
    end

    status == "true" ? "运行中" : "已停止"
  end


  def self.services
    {
      "agent" => "爬虫节点",
      "supervisor" => "节点监控器",
      "controller" => "主机控制器",
      "dispatcher" => "任务分发器",
      "loader" => "数据loaders",
      "receiver" => "数据接收器"
    }
  end


  def self.get_service_name(service)
    services[service]
  end

end
