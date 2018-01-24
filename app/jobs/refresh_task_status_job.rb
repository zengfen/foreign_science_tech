class RefreshTaskStatusJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	# Do something later
  	SpiderTask.refresh_task_status
  end
end
