# == Schema Information
#
# Table name: subtasks
#
#  id              :string(32)       not null, primary key
#  log_spider_id   :integer
#  status          :integer
#  content         :text(65535)
#  error_content   :text(65535)
#  error_at        :bigint
#  competed_at     :bigint
#  error_code      :integer
#  Indexes
#
#  index_subtasks_on_log_spider_id  (log_spider_id)
#  log_spider_id                    (log_spider_id)
#  ts                         (log_spider_id,status)
#

class Subtask < ApplicationRecord
  TypeSubtaskStart = 1
  TypeSubtaskSuccess = 2
  TypeSubtaskError = 3


  # 每个任务的redis key
  def self.task_key(spider_task_id)
    "foreign_sci_tec_tasks_#{spider_task_id}"
  end

  def self.task_pause_key(spider_task_id)
    "foreign_sci_tec_pouse_tasks_#{spider_task_id}"
  end

  # 任务结果缓存的redis key
  def self.task_success_key(spider_task_id)
    "foreign_sci_tec_tasks_success_#{spider_task_id}"
  end

  def self.task_error_key(log_spider_id)
    "foreign_sci_tec_tasks_error_#{log_spider_id}"
  end
  
  def self.make_id(line)
    id = Digest::MD5.hexdigest(line["spider_name"] + line["mode"] + line["body"].to_json)
    return id
  end
end
