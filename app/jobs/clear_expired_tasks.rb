class ClearExpiredTasks < ApplicationJob
  queue_as :default

  def perform(*args)
    SpiderTask.clear_all

    RefreshTaskStatusJob.set(wait_until: Date.tomorrow).perform_later
  end
end
