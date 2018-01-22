class CycleTaskJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	# Do something later
  	sct = SpiderCycleTask.find_by(id:args[0]["id"] )
  	sct.create_sub_task
  	sct.update_next_time
  end
end
