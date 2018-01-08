# == Schema Information
#
# Table name: media_accounts
#
#  id         :integer          not null, primary key
#  name       :string
#  short_name :string
#  account    :string
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class MediaAccountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
