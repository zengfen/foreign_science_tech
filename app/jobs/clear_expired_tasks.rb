class ClearExpiredTasks < ApplicationJob
  queue_as :default

  def perform(*args)
    SpiderTask.clear_all

    RefreshTaskStatusJob.set(wait_until: Date.tomorrow.to_datetime).perform_later
  end
end
