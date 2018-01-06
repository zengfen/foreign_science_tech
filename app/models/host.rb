# == Schema Information
#
# Table name: hosts
#
#  id                  :integer          not null, primary key
#  extranet_ip         :inet
#  intranet_ip         :inet
#  network_environment :integer          default("1")
#  cpu                 :string
#  memory              :string
#  disk                :string
#  host_status         :integer          default("0")
#  process_status      :integer          default("0")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Host < ApplicationRecord

	def self.network_environments
		{"境内"=>1, "境外"=>2}
	end
	
	def network_environment_cn
		Spider.network_environments.invert[self.network_environment]
	end
end
