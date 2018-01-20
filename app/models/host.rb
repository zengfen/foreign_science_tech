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

	def self.network_environments
		{"境内"=>1, "境外"=>2}
	end

	def network_environment_cn
		Host.network_environments.invert[self.network_environment]
	end


  def self.get_status(heartbeat_at, status)
    if Time.now - heartbeat_at > 30 && status == "true"
      return "未知"
    end

    status == "true" ? "运行中" : "已停止"
  end
end
