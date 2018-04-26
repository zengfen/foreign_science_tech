class DelHostMonitorsJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	# Do something later
  	HostMonitor.daily_delete
  end

end