class UncompletedTasksJob < ApplicationJob
  queue_as :uncompleted_tasks

  def perform(*args)
    SpiderTask.where(status:[SpiderTask::TypeTaskStart,SpiderTask::TypeTaskReopen]).each do |spider_task|
      puts "==uncompleted_spider_task_id====#{spider_task.id}="
      spider_task.process_status
    end
  end
end
