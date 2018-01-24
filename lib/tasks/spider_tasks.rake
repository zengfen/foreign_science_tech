namespace :spider_tasks  do

	namespace :refresh_status do 
	  desc "This is for start refresh status"
	  task :start => :environment do
	    job = Sidekiq::Cron::Job.find "RefreshTaskStatusJob"
			if job.blank?
				Sidekiq::Cron::Job.create(name: "RefreshTaskStatusJob", cron: "*/5 * * * * Asia/Shanghai", class: 'RefreshTaskStatusJob') 
				puts "job start success!"
			else
				puts "job already exist!"
			end
	  end

	  desc "This is for stop refresh status"
	  task :stop => :environment do
	    job = Sidekiq::Cron::Job.find "RefreshTaskStatusJob"
	    if !job.blank?
		  	Sidekiq::Cron::Job.destroy "RefreshTaskStatusJob" 
		  	puts "job stop success!"
		  else
		  	puts "job not exist!"
		  end
	  end
	end

end