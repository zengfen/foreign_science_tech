class TSkJobInstancesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    puts "==spider_name====#{args["spider_name"]}="
    spider = Spider.where(spider_name:args["spider_name"])
    res = @spider.start_task(SpiderTask::RealTimeTask)
  end
end
