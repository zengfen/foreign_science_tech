# == Schema Information
#
# Table name: spiders
#
#  id                  :integer          not null, primary key
#  spider_name         :string
#  spider_type         :integer
#  network_environment :integer          default("1")
#  proxy_support       :boolean          default("false")
#  has_keyword         :boolean          default("false")
#  template_name       :string
#  category            :string
#  additional_function :json             is an Array
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  control_template_id :integer
#

require 'test_helper'

class SpiderTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
