class RefreshMediaAccountsJob < ApplicationJob
  queue_as :default

  def perform(*args)
  	# Do something later
  	MediaAccount.daily_update
  end
end
