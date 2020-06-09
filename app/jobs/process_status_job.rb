class ProcessStatusJob < ApplicationJob
  queue_as :default

  # def perform(spider_task_id)
  def perform(*args)
    SpiderTask.where(status:[SpiderTask::TypeTaskStart,SpiderTask::TypeTaskReopen]).each do |spider_task|
      puts "==spider_task_id====#{spider_task.id}="
      spider_task.process_status
    end
    # puts "==spider_task_id====#{spider_task_id}="
    # spider_task = SpiderTask.find(spider_task_id) rescue nil
    # if spider_task.present?
    #   spider_task.process_status
    # end
  end
end
