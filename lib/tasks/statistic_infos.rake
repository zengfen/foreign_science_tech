
namespace :statistic_infos  do

	namespace :refresh_job do 
	  desc "This is for start refresh statistic info "
	  task :start => :environment do
	    job = Sidekiq::Cron::Job.find "RefreshStatisticInfoJob"
			if job.blank?
				Sidekiq::Cron::Job.create(name: "RefreshStatisticInfoJob", cron: "*/5 * * * * Asia/Shanghai", class: 'RefreshStatisticInfoJob') 
				puts "job start success!"
			else
				puts "job already exist!"
			end
	  end

	  desc "This is for stop refresh statistic info"
	  task :stop => :environment do
	    job = Sidekiq::Cron::Job.find "RefreshStatisticInfoJob"
	    if !job.blank?
		  	Sidekiq::Cron::Job.destroy "RefreshStatisticInfoJob" 
		  	puts "job stop success!"
		  else
		  	puts "job not exist!"
		  end
	  end
	end

end