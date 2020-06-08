namespace :foreign_science_tech  do

	namespace :process_status do
	  desc "This is for start process status"
	  task :start => :environment do
	    job = Sidekiq::Cron::Job.find "ProcessStatusJob"
			if job.blank?
				Sidekiq::Cron::Job.create(name: "ProcessStatusJob", cron: "*/10 * * * * Asia/Shanghai", class: 'ProcessStatusJob')
				puts "job start success!"
			else
				puts "job already exist!"
			end
	  end

	  desc "This is for stop refresh status"
	  task :stop => :environment do
	    job = Sidekiq::Cron::Job.find "ProcessStatusJob"
	    if !job.blank?
		  	Sidekiq::Cron::Job.destroy "ProcessStatusJob"
		  	puts "job stop success!"
		  else
		  	puts "job not exist!"
		  end
	  end
	end

end
# namespace :task  do

#   namespace :spider do
#     desc "This is for starting listen status job!"
#     task :run => :environment do
#       WashingtonpostCom.new.item('{"link":"https://www.washingtonpost.com/news/innovations/"}')
#     end
#   end
# end