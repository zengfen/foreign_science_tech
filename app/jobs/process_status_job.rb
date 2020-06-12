class ProcessStatusJob < ApplicationJob
  queue_as :process_status

  def perform(spider_task_id)
  # def perform(*args)
    # SpiderTask.where(status:[SpiderTask::TypeTaskStart,SpiderTask::TypeTaskReopen]).each do |spider_task|
    #   puts "==spider_task_id====#{spider_task.id}="
    #   spider_task.process_status
    # end
    GC.enable
    puts "==spider_task_id====#{spider_task_id}="
    spider_task = SpiderTask.find(spider_task_id) rescue nil
    GC.enable
    if spider_task.present?
      spider_task.process_status
    end
  end
end
