# == Schema Information
#
# Table name: host_monitors
#
#  id                  :integer          not null, primary key
#  extranet_ip         :inet
#  intranet_ip         :inet
#  network_environment :integer          default("1")
#  host_status         :integer          default("0")
#  process_status      :integer          default("0")
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

end
