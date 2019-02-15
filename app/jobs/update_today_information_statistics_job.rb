class UpdateTodayInformationStatisticsJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	InformationStatistics.new.renew_statistics_today
  end
end