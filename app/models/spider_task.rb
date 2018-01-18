# == Schema Information
#
# Table name: spider_tasks
#
#  id              :integer          not null, primary key
#  spider_id       :integer
#  level           :integer          default(1)
#  keyword         :string
#  special_tag     :string
#  status          :integer          default(0)
#  success_count   :integer          default(0)
#  fail_count      :integer          default(0)
#  refresh_time    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  max_retry_count :integer          default(2)
#

class SpiderTask < ApplicationRecord
  validates :spider_id, presence: true
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :max_retry_count, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }

  belongs_to :spider

  after_create :enqueue

  def status_cn
    cn_hash = { 0 => '未执行', 1 => '执行中', 2 => '执行结束' }
    cn_hash[status]
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
      'extra_config' => {}
    }

    if self.spider.network_environment == 1
      $archon_redis.zadd("archon_internal_tasks", self.level, self.id)
    else
      $archon_redis.zadd("archon_external_tasks", self.level, self.id)
    end

    $archon_redis.hset("archon_task_details_#{self.id}", task["task_md5"], task.to_json)
    $archon_redis.zadd("tasks_#{self.id}", Time.now.to_i, task["task_md5"])
  end
end
