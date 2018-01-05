# == Schema Information
#
# Table name: spider_tasks
#
#  id            :integer          not null, primary key
#  spider_id     :integer
#  level         :integer          default("1")
#  keyword       :string
#  special_tag   :string
#  status        :integer          default("0")
#  success_count :integer          default("0")
#  fail_count    :integer          default("0")
#  refresh_time  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'test_helper'

class SpiderTaskTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
