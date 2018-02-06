# == Schema Information
#
# Table name: social_account_monitors
#
#  id           :integer          not null, primary key
#  account_type :string
#  spider_id    :integer
#  cycle_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class SocialAccountMonitor < ApplicationRecord
end
