class DispatcherBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection DispatcherDB


  def self.migrate_data
    $archon_redis.smembers("archon_available_tasks").each do |x|
      puts x
      puts SpiderTask.find(x).max_retry_count
    end
  end
end
