class TSkJobInstancesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "==spider_name====#{args[0]["spider_name"]}==#{args[0]}=="

    # if SpiderTask.where("created_at >= ? and task_type = ?",Date.today,SpiderTask::CycleTask).blank?
    #   spider = Spider.where(spider_name: args[0]["spider_name"]).first
    #   _, spider_task = spider.create_spider_task(SpiderTask::CycleTask)
    # end
    #
    # SpiderTask.where(status: [SpiderTask::TypeTaskStart, SpiderTask::TypeTaskStop]).each do |spdier_task|
    #   res2 = spider_task.start_task
    # end

    spider = Spider.where(spider_name:args[0]["spider_name"]).first
    res,spider_task = spider.create_spider_task(SpiderTask::CycleTask)
    if res[:type] == "success"
      res2 = spider_task.start_task
    end
  end
end
