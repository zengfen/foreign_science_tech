class ClearExpiredTasks < ApplicationJob
  queue_as :default

  def perform(*args)
    SpiderTask.clear_all

    ClearExpiredTasks.set(wait_until: (Time.now + 1.hour).to_datetime).perform_later
  end
end
