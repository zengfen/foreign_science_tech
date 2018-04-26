namespace :hosts  do

	namespace :refresh_data do 
	  desc "This is for start refresh host info"
	  task :start => :environment do
      if HostsRefreshTask.is_running?
		  	puts "task process is already running!"
		  else
		  	HostsRefreshTask.start
		  	puts "task start successfully!"
		  end
			

	  end

	  desc "This is for stop refresh host info"
	  task :stop => :environment do
	    HostsRefreshTask.stop
	  end
 end

 	namespace :auto_delete_histroy do 
	  desc "This is for start delete host history automatically"
	  task :start => :environment do
	    job = Sidekiq::Cron::Job.find "DelHostMonitorsJob"
			if job.blank?
				Sidekiq::Cron::Job.create(name: "DelHostMonitorsJob", cron: "0 0 * * * Asia/Shanghai", class: 'DelHostMonitorsJob') 
				puts "job start success!"
			else
				puts "job already exist!"
			end
	  end

	  desc "TThis is for stop delete host history"
	  task :stop => :environment do
	    job = Sidekiq::Cron::Job.find "DelHostMonitorsJob"
	    if !job.blank?
		  	Sidekiq::Cron::Job.destroy "DelHostMonitorsJob" 
		  	puts "job stop success!"
		  else
		  	puts "job not exist!"
		  end
	  end
	end

end


