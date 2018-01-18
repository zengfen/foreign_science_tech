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
end
