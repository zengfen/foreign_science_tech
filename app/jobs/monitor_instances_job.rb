class MonitorInstancesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    TSkJobInstance.all.each do |instance|
      puts "==instance_id====#{instance.id}="
      instance.init_instance_job
    end
  end
end
