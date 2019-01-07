class RefreshTaskStatusJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	SpiderTask.refresh_task_status
    Account.check_invalid_accounts
  end
end
