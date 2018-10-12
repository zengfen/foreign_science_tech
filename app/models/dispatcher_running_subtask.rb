# == Schema Information
#
# Table name: running_subtasks
#
#  id         :string(255)      not null, primary key
#  task_id    :integer
#  ip         :string(255)
#  created_at :bigint(8)
#  account_id :integer
#

class DispatcherRunningSubtask < DispatcherBase
  self.table_name = "running_subtasks"


  def self.rollback(task_id)
    spider_task = SpiderTask.find(task_id)
    DispatcherRunningSubtask.where(task_id: task_id).each do |x|
      spider_task.retry_task(x.id)
      x.destroy
    end
  end
end
