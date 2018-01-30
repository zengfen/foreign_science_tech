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

require 'test_helper'

class HostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
