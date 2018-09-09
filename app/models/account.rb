# == Schema Information
#
# Table name: accounts
#
#  id                  :bigint(8)        not null, primary key
#  content             :string
#  account_type        :integer
#  control_template_id :integer
#  valid_time          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  valid_ips           :text             default([]), is an Array
#

class Account < ApplicationRecord
  attr_accessor :contents

  # validates :content, presence: true, uniqueness: { case_sensitive: false }

  belongs_to :control_template
  after_create :setup_redis
  before_destroy :clear_redis

  def self.account_types
    {
      0 => '账号',
      1 => 'Token',
      2 => 'Cookies'
    }
  end

  def account_type_cn
    self.class.account_types[account_type]
  end

  def is_valid?
    Time.now < valid_time
  end

  def real_is_valid?
    (Time.now + 10.minutes) < valid_time
  end

  def save_with_split!
    return { 'error' => '内容为空' } if contents.blank?

    if control_template.is_bind_ip && valid_ips.blank?
      return { 'error' => '选择IP' }
    end

    contents.split("\n").each do |line|
      next if line.blank?

      account = Account.new(content: line.strip,
                            account_type: account_type,
                            valid_time: valid_time,
                            valid_ips: valid_ips,
                            control_template_id: control_template_id)
      account.save
    end

    { 'success' => '保存成功！' }
  end

  def self.create_default_account!(template_id)
    Account.create(content: '-',
                   account_type: 0,
                   valid_time: (Time.now + 10.years),
                   control_template_id: template_id)
  end

  #  发现新的host之后，要同步所有的账号信息过去, 如果账号需要绑定到ip上的话
  #  如果一个账号的有效期过了，要清除要对应的account/token
  #  account删除之后也要清除，都要通过定时任务来完成
  def setup_redis
    return if valid_time < Time.now + 10.minutes
    if control_template.is_bind_ip
      agent_ips = if control_template.is_internal
                    DispatcherHost.internal_agents
                  else
                    DispatcherHost.external_agents
                  end

      agent_ips = valid_ips unless valid_ips.blank?

      agent_ips.each do |x|
        $archon_redis.zadd("archon_template_ip_accounts_#{control_template_id}_#{x}", Time.now.to_i * 1000, id)
      end
    else
      $archon_redis.zadd("archon_template_accounts_#{control_template_id}", Time.now.to_i * 1000, id)
    end

    DispatcherAccount.create(id: id, content: content, valid_time: valid_time.to_i) rescue "Account Exist"
  end

  #  过期之后要执行这个来删除对应的数据
  #  FIXME  加入周期任务中
  def clear_redis
    return if valid_time > Time.now + 10.minutes

    $archon_redis.keys("archon_template_accounts_#{control_template_id}").each do |k|
      $archon_redis.zrem(k, id)
    end

    $archon_redis.keys("archon_template_ip_accounts_#{control_template_id}_*").each do |k|
      $archon_redis.zrem(k, id)
    end

    DispatcherAccount.find(id).delete
  end

  def self.check_invalid_accounts
    accounts = Account.where('valid_time < ?', Time.now + 10.minutes)
    accounts.each do |x|
      m = DispatcherAccount.find_by_id(x.id)
      if !m.blank?
        m.delete
      end
      $archon_redis.keys("archon_template_accounts_#{x.control_template_id}").each do |k|
        $archon_redis.zrem(k, x.id)
      end

      $archon_redis.keys("archon_template_ip_accounts_#{x.control_template_id}_*").each do |k|
        $archon_redis.zrem(k, x.id)
      end
    end
  end


  def self.expired_accounts
    Account.where('valid_time < ?', Time.now + 10.minutes)
  end
end
