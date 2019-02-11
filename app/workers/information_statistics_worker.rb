class InformationStatisticsWorker
  include Sidekiq::Worker

  def perform
    InformationStatistics.new.renew_statistics
  end

end