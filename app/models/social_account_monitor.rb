# == Schema Information
#
# Table name: social_account_monitors
#
#  id              :integer          not null, primary key
#  account_type    :string
#  spider_id       :integer
#  cycle_type      :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  max_retry_count :integer          default(1)
#  level           :integer          default(1)
#  special_tag     :string
#

class SocialAccountMonitor < ApplicationRecord
  belongs_to :spider

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

  def self.create_or_update!(params)
    monitor = where(account_type: params[:social_account_monitor][:account_type]).first
    if monitor.blank?
      monitor = new
      monitor.account_type = params[:social_account_monitor][:account_type]
    end

    monitor.spider_id = params[:social_account_monitor][:spider_id]
    monitor.cycle_type = params[:social_account_monitor][:cycle_type]
    monitor.save
  end


  def monitor_accounts(accounts)
    key = "archon_monitor_#{self.account_type}"
    accounts.each do |account|
      $archon_redis.hsetnx(key, account, "")
    end
  end

  def create_spider_task
    key = "archon_monitor_#{self.account_type}"

    current_ts  = Time.now.to_i
  end
end
