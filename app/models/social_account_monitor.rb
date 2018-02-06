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
  def self.account_types
    %w[twitter facebook youtube linkedin]
  end

  def self.cycle_types
    {
      'day' => '天',
      'week' => '周',
      'month' => '月'
    }
  end

  def cycle_type_cn
    self.class.cycle_types[cycle_type]
  end
end
