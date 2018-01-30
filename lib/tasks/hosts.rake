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

end


