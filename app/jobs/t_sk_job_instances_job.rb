class TSkJobInstancesJob < ApplicationJob
  queue_as :t_sk_job_instances

  def perform(*args)
    spider_name = args[0]["spider_name"]
    puts "==spider_name====#{spider_name}===="
    spider = Spider.where(spider_name:spider_name).first
    res,spider_task = spider.create_spider_task(SpiderTask::CycleTask)
    if res[:type] == "success"
      res2 = spider_task.start_task
    end
  end
end
