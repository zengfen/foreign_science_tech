namespace :foreign_science_tech do

  namespace :monitor_instances do
    desc "This is for start monitor t_sk_job_instances"
    task :start => :environment do
      job = Sidekiq::Cron::Job.find "MonitorInstancesJob"
      if job.blank?
        Sidekiq::Cron::Job.create(name: "MonitorInstancesJob", cron: "* */2 * * * Asia/Shanghai", class: 'MonitorInstancesJob')
        puts "job start success!"
      else
        job.enable!
        puts "job already exist!"
      end
    end

    desc "This is for stop monitor t_sk_job_instances"
    task :stop => :environment do
      job = Sidekiq::Cron::Job.find "MonitorInstancesJob"
      if !job.blank?
        job.disable!
        puts "job stop success!"
      else
        puts "job not exist!"
      end
    end

    desc "This is for stop monitor t_sk_job_instances"
    task :stop_all_instances => :environment do
      all_instances = TSkJobInstance.all.map { |x| x.job_name }
      all_instances.each do |job_name|
        job = Sidekiq::Cron::Job.find job_name
        if job.present?
          job.destroy
          puts "#{job_name} job stop success!"
        else
          puts "#{job_name} job   not exist!"
        end
      end
    end
  end

end