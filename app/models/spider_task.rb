# == Schema Information
#
# Table name: spider_tasks
#
#  id                   :integer          not null, primary key
#  spider_id            :integer
#  level                :integer          default("1")
#  keyword              :string
#  special_tag          :string
#  status               :integer          default("0")
#  success_count        :integer          default("0")
#  fail_count           :integer          default("0")
#  refresh_time         :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  max_retry_count      :integer          default("2")
#  warning_count        :integer          default("0")
#  spider_cycle_task_id :integer
#  task_type            :integer          default("1")
#

class SpiderTask < ApplicationRecord
  validates :spider_id, presence: true
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :max_retry_count, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }

  belongs_to :spider
  belongs_to :spider_cycle_task,required: false

  scope :cycle, -> {where().not(task_type: 1)}
  scope :not_cycle, -> {where(task_type: 1)}

  after_create :enqueue
  before_destroy :clear_related_datas!

  def status_cn
    cn_hash = { 0 => '未启动', 1 => '执行中', 2 => '执行结束', 3 => "已暂停"}
    cn_hash[status]
  end


  def can_start?
    self.status == 0 || self.status == 3
  end

  def start!
    return if !can_start?

    self.status = 1
    self.save

    if self.spider.network_environment == 1
      $archon_redis.zadd("archon_internal_tasks", self.level, self.id)
    else
      $archon_redis.zadd("archon_external_tasks", self.level, self.id)
    end
  end


  def can_stop?
    self.status == 1
  end


  def stop!
    return if !can_stop?

    self.status = 3
    self.save

    if self.spider.network_environment == 1
      $archon_redis.zrem("archon_internal_tasks", self.id)
    else
      $archon_redis.zrem("archon_external_tasks", self.id)
    end

  end


  def save_with_spilt_keywords
    if spider.has_keyword && !spider.blank?
      keywords = keyword.split(',')
      keywords.each do |keyword|
        spider_task = dup
        spider_task.keyword = keyword
        return { 'error' => spider_task.errors.full_messages.join('\n') } unless spider_task.save
      end
    else
      return { 'error' => spider_task.errors.full_messages.join('\n') } unless save
    end
    { 'success' => '保存成功！' }
  end


  def enqueue
    # // ArchonInternalTaskKey 国内顶级任务的列表
    # ArchonInternalTaskKey = "archon_internal_tasks"

    # // ArchonExternalTaskKey 境外任务
    # ArchonExternalTaskKey = "archon_external_task"

    # // ArchonTaskDetailHashKeyFormat  md5 -> task
    # ArchonTaskDetailHashKeyFormat = "archon_task_details_%s"
    task = {
      'task_id' => id,
      'task_md5' => Digest::MD5.hexdigest("#{id}#{keyword}{}"),
      'params' => {},
      'url' => keyword, # keyword or url
      'rate_limit_url' => '',
      'priority' => level,
      'site' => '',
      'archon_template_id' => spider.template_name,
      'proxy' => '',
      'retry_count' => 0,
      'max_retry_count' => max_retry_count,
      'extra_config' => {special_tag: self.special_tag}
    }


    $archon_redis.hset("archon_task_details_#{self.id}", task["task_md5"], task.to_json)
    $archon_redis.zadd("archon_tasks_#{self.id}", Time.now.to_i, task["task_md5"])
  end


  def success_count
    $archon_redis.scard("archon_completed_tasks_#{self.id}")
  end


  def fail_count
    $archon_redis.scard("archon_discard_tasks_#{self.id}")
  end

  def error_count
    $archon_redis.hlen("archon_task_errors_#{self.id}")
  end

  def warning_count
    $archon_redis.scard("archon_warning_tasks_#{self.id}")
  end


  def current_total_count
    $archon_redis.hlen("archon_task_details_#{self.id}")
  end


  def current_running_count
    current_total_count - success_count - fail_count
  end


  def maybe_finished?
    # current_running_count == 0
    current_total_count == success_count + fail_count
  end


  def clear_related_datas!
    if self.spider.network_environment == 1
      $archon_redis.zrem("archon_internal_tasks", self.id)
    else
      $archon_redis.zrem("archon_external_tasks", self.id)
    end

    redis_keys = []
    redis_keys << "archon_tasks_#{self.id}"

    %w(task_details completed_tasks discard_tasks warning_tasks task_errors ).map{|x| redis_keys<< "archon_#{x}_#{self.id}" }

    redis_keys.map{|x| $archon_redis.del(x)}
  end

end
