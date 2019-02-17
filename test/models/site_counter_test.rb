# == Schema Information
#
# Table name: site_counters
#
#  site         :string(255)
#  cdate        :string(255)
#  result_count :integer
#
# Indexes
#
#  index_site_counters_on_site_and_cdate  (site,cdate) UNIQUE
#

require 'test_helper'

class SiteCounterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
