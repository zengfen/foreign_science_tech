class MonitorSidekiqJob < ApplicationJob
  queue_as :monitor_sidekiq

  def perform(*args)
    SpiderTask.where(status:[SpiderTask::TypeTaskStart,SpiderTask::TypeTaskReopen]).where("created_at < ?",Time.now - 2.hour).each do |spider_task|
      spider_task.process_status
    end
  end
end


