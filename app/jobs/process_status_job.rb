class ProcessStatusJob < ApplicationJob
  queue_as :default

  def perform(*args)
    SpiderTask.where(status:[SpiderTask::TypeTaskStart,SpiderTask::TypeTaskStop,SpiderTask::TypeTaskReopen]).each do |spider_task|
      puts "==spider_task====#{spider_task.id}="
      spider_task.process_status
    end
  end
end
