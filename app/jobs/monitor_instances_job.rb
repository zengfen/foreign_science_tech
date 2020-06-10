class MonitorInstancesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    spider_names = Spider.where(status:1).pluck(:spider_name)
    TSkJobInstance.where(spider_name:spider_names).each do |instance|
      puts "==instance_id====#{instance.id}="
      instance.init_instance_job
    end
  end
end
