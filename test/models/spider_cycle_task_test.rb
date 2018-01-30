# == Schema Information
#
# Table name: spider_cycle_tasks
#
#  id                  :integer          not null, primary key
#  spider_id           :integer
#  level               :integer          default("1")
#  keyword             :string
#  special_tag         :string
#  status              :integer          default("0")
#  success_count       :integer          default("0")
#  fail_count          :integer          default("0")
#  max_retry_count     :integer          default("2")
#  warning_count       :integer          default("0")
#  period              :string
#  next_time           :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  additional_function :json
#

require 'test_helper'

class SpiderCycleTaskTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
