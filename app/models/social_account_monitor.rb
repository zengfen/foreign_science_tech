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
    monitor.level = params[:social_account_monitor][:level]
    monitor.max_retry_count = params[:social_account_monitor][:max_retry_count]
    monitor.special_tag = params[:social_account_monitor][:special_tag]
    monitor.save
  end

  def monitor_accounts(accounts)
    key = "archon_monitor_#{account_type}"
    accounts.each do |account|
      $archon_redis.hsetnx(key, account, '')
    end
  end

  def create_spider_task
    key = "archon_monitor_#{account_type}"

    current_time = Time.now

    spider_task = SpiderTask.create(
      spider_id: spider_id,
      level: level,
      special_tag: special_tag,
      max_retry_count: max_retry_count,
      end_time: current_time
    )

    task_template = {
      'task_id' => spider_task.id,
      'task_md5' => Digest::MD5.hexdigest(''),
      'params' => {},
      'url' => '', # keyword or url
      'template_id' => spider.template_name,
      'account' => '',
      'proxy' => '',
      'retry_count' => 0,
      'max_retry_count' => max_retry_count,
      'extra_config' => { special_tag: special_tag, begin_time: begin_time, end_time: end_time }
    }

    cursor = '0'

    page = 0

    loop do
      puts page
      cursor, values = $archon_redis.hscan(key, cursor, count: 1000)
      time_array = []
      details_array = []
      urls_array = []

      values.each do |v|
        keyword = v[0]
        start_ts = v[1]
        task_template['task_md5'] = Digest::MD5.hexdigest("#{spider_task.id}#{keyword}{}")
        task_template['url'] = keyword
        if !start_ts.blank?
          task_template['extra_config'][:begin_time] = Time.at(start_ts.to_i)
          task_template['extra_config'][:end_time] = current_time
        else
          task_template['extra_config'][:begin_time] = ''
          task_template['extra_config'][:end_time] = current_time
        end
        time_array << keyword
        time_array << current_time.to_i.to_s

        details_array << task_template['task_md5']
        details_array << task_template.to_json

        urls_array << [Time.now.to_i, task_template['task_md5']]
      end

      $archon_redis.hmset(key, *time_array)
      $archon_redis.hmset("archon_task_details_#{spider_task.id}", *details_array)
      $archon_redis.zadd("archon_tasks_#{id}", urls_array)

      break if cursor == '0'

      page += 1
    end

    unless spider.control_template_id.blank?
      $archon_redis.hset('archon_task_account_controls', spider_task.id, spider.control_template.control_key)
    end

    $archon_redis.sadd('archon_available_tasks', spider_task.id)
  end
end
