class HostsRefreshTask
  def self.pid_file
    "tmp/pids/hosts_refresh_task.pid"
  end

  def self.log_file
     "log/hosts_refresh_task.log"
  end

  def self.is_running?

    return false if !File.exist?(pid_file)

    prev_pid = File.new(pid_file).to_a.first

    return false if prev_pid.blank?

    prev_pid = prev_pid.strip

    res = `ps -ef | awk -F ' ' {print'$2'}`.split("\n").include?(prev_pid)

    `rm #{pid_file}` unless res

    return res.present?

  end


  def self.write_pid
    File.open(pid_file, "w") do |file|
      file.puts Process.pid
    end
  end



  def self.write_exception(e)
      logger = Logger.new(log_file)  
      logger.level = Logger::DEBUG 
      logger.formatter = proc do |severity, datetime, progname, message| 
        "[#{datetime.to_s(:db)}] [#{severity}] #{message}\n"
      end
      info = {exception:e.class.to_s,message:e.message,time:Time.now.to_s}
      logger.error  info
  end


  def self.start
    if is_running?
      puts "task process is already running!"
      exit
    end
    
    #常驻进程
    Process.daemon(true)
    write_pid
       
    while true
      begin
        Host.load_host_datas
      rescue Exception =>e
        ActiveRecord::Base.connection.reconnect!  if e.message.to_s.include?('no connection to the server')
        write_exception(e)
      end

      sleep(10)
    end
  end


  def self.stop
    if  !is_running?
      puts "task not exist!"
      exit
    end

    prev_pid = File.new(pid_file).to_a.first

    prev_pid = prev_pid.strip
    `kill -9 #{prev_pid}`
    puts "task stop successfully!"
  end

end

