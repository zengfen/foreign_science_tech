class UpdateInformationStatisticsJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	InformationStatistics.new.renew_statistics
  end
end