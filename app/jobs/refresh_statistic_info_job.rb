class RefreshStatisticInfoJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	# Do something later
  	StatisticalInfo.refresh_data
  end
end