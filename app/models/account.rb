# == Schema Information
#
# Table name: accounts
#
#  id                  :integer          not null, primary key
#  content             :string
#  account_type        :integer
#  control_template_id :integer
#  valid_time          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Account < ApplicationRecord
  attr_accessor :contents

  #validates :content, presence: true, uniqueness: { case_sensitive: false }

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
    Time.now < valid_time ? '有效' : '无效'
  end

  def save_with_split!
    return { 'error' => '内容为空' } if contents.blank?

    contents.split("\n").each do |line|
      next if line.blank?

      account = Account.new(content: line.strip,
                            account_type: account_type,
                            valid_time: valid_time,
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
    if control_template.is_bind_ip
      $archon_redis.hgetall('archon_hosts').each do |ip, _|
        $archon_redis.zadd("archon_template_ip_accounts_#{control_template_id}_#{ip}", Time.now.to_i * 1000, content)
      end
    else
      $archon_redis.zadd("archon_template_accounts_#{control_template_id}", Time.now.to_i * 1000, content)
    end
  end

  #  过期之后要执行这个来删除对应的数据
  def clear_redis
    $archon_redis.keys("archon_template_accounts_#{control_template_id}").each do |k|
      $archon_redis.zrem(k, content)
    end

    $archon_redis.keys("archon_template_accounts_#{control_template_id}_*").each do |k|
      $archon_redis.zrem(k, content)
    end
  end
end
