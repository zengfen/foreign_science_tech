class ProcessStatusJob < ApplicationJob
  queue_as :default

  def perform(spdier_id)
    # SpiderTask.where(status:[SpiderTask::TypeTaskStart,SpiderTask::TypeTaskStop,SpiderTask::TypeTaskReopen]).each do |spider_task|
    #   puts "==spider_task====#{spider_task.id}="
    #   spider_task.process_status
    # end
    puts "==spdier_id====#{spdier_id}="
    spider_task = SpiderTask.find(spdier_id) rescue nil
    if spider_task.present?
      spider_task.process_status
    end
  end
end
