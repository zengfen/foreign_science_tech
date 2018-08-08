# == Schema Information
#
# Table name: spider_tasks
#
#  id                    :bigint(8)        not null, primary key
#  spider_id             :integer
#  level                 :integer          default(1)
#  keyword               :text
#  special_tag           :string
#  status                :integer          default(0)
#  success_count         :integer          default(0)
#  fail_count            :integer          default(0)
#  refresh_time          :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  max_retry_count       :integer          default(2)
#  warning_count         :integer          default(0)
#  spider_cycle_task_id  :integer
#  task_type             :integer          default(1)
#  additional_function   :json
#  is_split              :boolean          default(FALSE)
#  begin_time            :datetime
#  end_time              :datetime
#  current_task_count    :integer
#  current_success_count :integer
#  current_fail_count    :integer
#  current_warning_count :integer
#

class SpiderTask < ApplicationRecord
  validates :spider_id, presence: true
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :max_retry_count, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }

  belongs_to :spider
  belongs_to :spider_cycle_task, required: false

  scope :cycle, -> { where.not(task_type: 1) }
  scope :not_cycle, -> { where(task_type: 1) }
  scope :unfinished, -> { where.not(status: 2) }
  scope :finished, -> { where(status: 2) }

  after_create :setup_task_spider
  before_destroy :clear_related_datas!

  def status_cn
    cn_hash = { 0 => '未启动', 1 => '执行中', 2 => '执行结束', 3 => '已暂停' }
    cn_hash[status]
  end

  def is_finished?
    status == 2
  end

  def is_running?
    status == 1
  end

  def can_start?
    status == 0 || status == 3
  end

  def enqueue_level_task
    if spider.network_environment == 1
      $archon_redis.zadd('archon_internal_tasks', level, id)
    else
      $archon_redis.zadd('archon_external_tasks', level, id)
    end

    $archon_redis.hset('archon_available_tasks', id, max_retry_count)
  end

  def dequeue_level_task
    if spider.network_environment == 1
      $archon_redis.zrem('archon_internal_tasks', id)
    else
      $archon_redis.zrem('archon_external_tasks', id)
    end
  end

  def start!
    return unless can_start?

    self.status = 1
    save

    enqueue_level_task
  end

  def can_stop?
    status == 1
  end

  def stop!
    return unless can_stop?

    self.status = 3
    save

    dequeue_level_task
  end

  def special_tag_names
    tag_names = []
    special_tag.split(',').each do |x|
      st = begin
             SpecialTag.find(x)
           rescue StandardError
             nil
           end
      tag_names << st.tag if st
    end
    tag_names
  end

  def special_tag_transfor_id
    specital_tags_ids = special_tag.split(',').collect { |tag| SpecialTag.create_with(tag: tag, created_at: Time.now, updated_at: Time.now).find_or_create_by(tag: tag).id }.join(',')
    self.special_tag = specital_tags_ids
  end

  def tidb_table_name
    spider.tidb_table_name
  end

  def accounts_is_valid?
    spider.accounts_is_valid?
  end

  def save_with_spilt_keywords
    return { 'error' => '设置关键词!' } if spider.has_keyword && keyword.blank?

    return { 'error' => '账号都已过期' } unless accounts_is_valid?

    if spider.has_keyword
      keywords = keyword.split(',').collect(&:strip).uniq
      keywords.delete(nil)
      keywords.delete('')
      return { 'error' => '设置关键词!' } if keywords.blank?

      if is_split
        keywords.each do |keyword|
          spider_task = dup
          spider_task.keyword = keyword
          return { 'error' => spider_task.errors.full_messages.join('\n') } unless spider_task.save
        end
      else
        self.keyword = keywords.join(',')
        return { 'error' => errors.full_messages.join('\n') } unless save
      end
    else
      self.keyword = nil
      return { 'error' => errors.full_messages.join('\n') } unless save
    end

    enqueue

    { 'success' => '保存成功！' }
  end

  def enqueue
    # // ArchonInternalTaskKey 国内顶级任务的列表
    # ArchonInternalTaskKey = "archon_internal_tasks"

    # // ArchonExternalTaskKey 境外任务
    # ArchonExternalTaskKey = "archon_external_task"

    # // ArchonTaskDetailHashKeyFormat  md5 -> task
    # ArchonTaskDetailHashKeyFormat = "archon_task_details_%s"
    #

    b_time = ''
    b_time = begin_time.to_s unless begin_time.blank?

    e_time = ''
    e_time = end_time.to_s unless end_time.blank?

    task_template = {
      'task_id' => id,
      'task_md5' => Digest::MD5.hexdigest("#{id}#{keyword}{}#{spider.template_name}"),
      'params' => {},
      'url' => keyword, # keyword or url
      'template_id' => spider.template_name,
      'account' => '',
      'ignore_account' => false,
      'proxy' => '',
      'retry_count' => 0,
      'max_retry_count' => max_retry_count,
      'extra_config' => { special_tag: special_tag, additional_function: additional_function, begin_time: b_time, end_time: e_time }
    }

    need_account = !spider.control_template_id.blank?

    Rails.logger.info(need_account)

    archon_template_id = spider.control_template_id

    prefix_integer = 0

    unless archon_template_id.blank?
      prefix_integer = archon_template_id * 10_000_000_000_000
    end

    if spider.has_keyword && is_split
      task_template['task_md5'] = Digest::MD5.hexdigest("#{id}#{keyword}{}#{spider.template_name}")
      task_template['url'] = keyword
      DispatcherSubtask.create(id: task_template['task_md5'], task_id: id, content: task_template.to_json, retry_count: 0)
      $archon_redis.zadd("archon_tasks_#{id}", prefix_integer + Time.now.to_i * 1000, task_template['task_md5'])
    end

    if spider.has_keyword && !is_split
      if (split_group_count || 0) > 0
        keyword.split(',').each_slice(split_group_count).each do |kk|
          task_template['task_md5'] = Digest::MD5.hexdigest("#{id}#{k.join(',')}{}#{spider.template_name}")
          task_template['url'] = k.join(",")
          DispatcherSubtask.create(id: task_template['task_md5'], task_id: id, content: task_template.to_json, retry_count: 0)
          $archon_redis.zadd("archon_tasks_#{id}", prefix_integer + Time.now.to_i * 1000, task_template['task_md5'])
        end
      else
        keyword.split(',').each do |k|
          task_template['task_md5'] = Digest::MD5.hexdigest("#{id}#{k}{}#{spider.template_name}")
          task_template['url'] = k
          DispatcherSubtask.create(id: task_template['task_md5'], task_id: id, content: task_template.to_json, retry_count: 0)
          $archon_redis.zadd("archon_tasks_#{id}", prefix_integer + Time.now.to_i * 1000, task_template['task_md5'])
        end
      end

    end

    unless spider.has_keyword
      task_template['task_md5'] = Digest::MD5.hexdigest("#{id}#{keyword}{}#{spider.template_name}")
      task_template['url'] = keyword
      DispatcherSubtask.create(id: task_template['task_md5'], task_id: id, content: task_template.to_json, retry_count: 0)
      $archon_redis.zadd("archon_tasks_#{id}", prefix_integer + Time.now.to_i * 1000, task_template['task_md5'])
    end

    $archon_redis.hset('archon_available_tasks', id, max_retry_count)
  end

  def success_count
    DispatcherSubtaskStatus.where(task_id: id).where('status = 1 or status = 2').count
  end

  def fail_count
    DispatcherSubtaskStatus.where(task_id: id).where('status = 3').count
  end

  def warning_count
    DispatcherSubtaskStatus.where(task_id: id).where('status = 2').count
  end

  def current_total_count
    DispatcherSubtask.where(task_id: id).count
    # $archon_redis.hlen("archon_task_details_#{id}")
  end

  def current_running_count
    current_total_count - success_count - fail_count
  end

  def result_count
    DispatcherTaskResultCounter.where(task_id: id).sum(&:result_count)
    # $archon_redis.zrange("archon_task_total_results_#{id}", 0, -1, withscores: true).map { |x| x[1] }.sum.to_i
    # rescue StandardError
    # 0
  end

  def maybe_finished?
    # current_running_count == 0
    current_total_count == success_count + fail_count
  end

  # 重试失败任务
  # 删除fail_task 记录
  # 重新添加到执行队列
  # 任务运行
  def retry_fail_task(task_md5)
    subtaskStatus = DispatcherSubtaskStatus.where(id: task_md5, status: 3).first
    return if subtaskStatus.blank?

    subtask = DispatcherSubtask.where(id: task_md5).first
    return if subtask.blank?
    subtask.retry_count = 0
    subtask.save

    subtaskStatus.destroy

    task = JSON.parse(subtask.content)

    archon_template_id = $archon_redis.hget('archon_template_control_id', task['template_id'])
    prefix_integer = 0

    unless archon_template_id.blank?
      prefix_integer = archon_template_id.to_i * 10_000_000_000_000
    end

    if prefix_integer > 0 && (task['ignore_account'].blank? || !task['ignore_account'])
      $archon_redis.zadd("archon_tasks_#{id}", prefix_integer + Time.now.to_i * 1000, task_md5)
    else
      $archon_redis.zadd("archon_tasks_#{id}", Time.now.to_i * 1000, task_md5)
    end

    if maybe_finished? || is_finished?
      self.status = 1
      save

      enqueue_level_task
    end
  end


  def retry_task(task_md5)
    subtask = DispatcherSubtask.where(id: task_md5).first
    return if subtask.blank?
    subtask.retry_count = 0
    subtask.save

    subtaskStatus.destroy

    task = JSON.parse(subtask.content)

    archon_template_id = $archon_redis.hget('archon_template_control_id', task['template_id'])
    prefix_integer = 0

    unless archon_template_id.blank?
      prefix_integer = archon_template_id.to_i * 10_000_000_000_000
    end

    if prefix_integer > 0 && (task['ignore_account'].blank? || !task['ignore_account'])
      $archon_redis.zadd("archon_tasks_#{id}", prefix_integer + Time.now.to_i * 1000, task_md5)
    else
      $archon_redis.zadd("archon_tasks_#{id}", Time.now.to_i * 1000, task_md5)
    end

    if maybe_finished? || is_finished?
      self.status = 1
      save

      enqueue_level_task
    end
  end

  def retry_all_fail_task
    return if fail_count == 0

    # need_account = !spider.control_template_id.blank?

    DispatcherSubtaskStatus.where(task_id: id, status: 3).each do |subtaskStatus|
      subtask = DispatcherSubtask.where(id: subtaskStatus.id).first
      next if subtask.blank?

      task = JSON.parse(subtask.content)

      archon_template_id = $archon_redis.hget('archon_template_control_id', task['template_id'])
      prefix_integer = 0

      unless archon_template_id.blank?
        prefix_integer = archon_template_id.to_i * 10_000_000_000_000
      end

      if prefix_integer > 0 && (task['ignore_account'].blank? || !task['ignore_account'])
        $archon_redis.zadd("archon_tasks_#{id}", prefix_integer + Time.now.to_i * 1000, subtask.id)
      else
        $archon_redis.zadd("archon_tasks_#{id}", Time.now.to_i * 1000, subtask.id)
      end

      subtaskStatus.destroy
    end

    if maybe_finished? || is_finished?
      self.status = 1
      save

      enqueue_level_task
    end
  end

  def del_fail_task(task_md5)
    # return unless $archon_redis.sismember("archon_discard_tasks_#{id}", task_md5)
    # $archon_redis.srem("archon_discard_tasks_#{id}", task_md5)
    # $archon_redis.hdel("archon_task_details_#{id}", task_md5)
  end

  def clear_related_datas!
    dequeue_level_task # fix me

    redis_keys = []
    redis_keys << "archon_tasks_#{id}_0"
    redis_keys << "archon_tasks_#{id}_1"
    redis_keys << "archon_tasks_#{id}"

    # %w[task_details completed_tasks discard_tasks warning_tasks task_errors].map { |x| redis_keys << "archon_#{x}_#{id}" }

    redis_keys.map { |x| $archon_redis.del(x) }

    $archon_redis.hdel('archon_task_account_controls', id)
    $archon_redis.hdel('archon_task_controls', id)

    $archon_redis.hdel('archon_available_tasks', id)

    DispatcherRunningSubtask.where(task_id: id).delete_all
    DispatcherSubtask.where(task_id: id).delete_all
    DispatcherSubtaskStatus.where(task_id: id).delete_all
    DispatcherTaskResultCounter.where(task_id: id).delete_all
  end

  def self.refresh_task_status
    SpiderTask.where(status: 1).find_each(&:update_finished_status!)
  end

  def update_self_counters!
    update_attributes(
      current_success_count: success_count,
      current_fail_count: fail_count,
      current_warning_count: warning_count,
      current_task_count: current_total_count
    )
  end

  def update_finished_status!
    return unless is_running?

    update_self_counters!

    if maybe_finished?
      update_attributes(status: 2)

      $archon_redis.hdel('archon_available_tasks', id)
      dequeue_level_task
    end
  end

  def setup_task_spider
    # $archon_redis.hset("archon_task_spider", self.id, self.spider_id)
    $archon_redis.hset('archon_task_controls', id, spider.control_template_id_details)
  end

  def self.clear_expired_tasks
    tasks = SpiderTask.where(status: 2).where('created_at < ?', 1.month.ago)
    return if tasks.blank?

    tasks.each do |task|
      DispatcherRunningSubtask.where(task_id: task.id).delete_all
      DispatcherSubtask.where(task_id: task.id).delete_all
      DispatcherSubtaskStatus.where(task_id: task.id).delete_all
    end
  end
end
