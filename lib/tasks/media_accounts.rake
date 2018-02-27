
namespace :media_accounts  do

	namespace :refresh_job do 
	  desc "This is for start refresh media account data"
	  task :start => :environment do
	    job = Sidekiq::Cron::Job.find "RefreshMediaAccountsJob"
			if job.blank?
				Sidekiq::Cron::Job.create(name: "RefreshMediaAccountsJob", cron: "0 0 * * * Asia/Shanghai", class: 'RefreshMediaAccountsJob') 
				puts "job start success!"
			else
				puts "job already exist!"
			end
	  end

	  desc "This is for stop refresh media account data"
	  task :stop => :environment do
	    job = Sidekiq::Cron::Job.find "RefreshMediaAccountsJob"
	    if !job.blank?
		  	Sidekiq::Cron::Job.destroy "RefreshMediaAccountsJob" 
		  	puts "job stop success!"
		  else
		  	puts "job not exist!"
		  end
	  end
	end

end