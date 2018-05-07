class DispatcherBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection DispatcherDB


  def self.migrate_data
    data = {}
    $archon_redis.smembers("archon_available_tasks").each do |x|
      data[x] =  SpiderTask.find(x).max_retry_count
    end

    puts data
    $archon_redis.del("archon_available_tasks")

    data.each do |k, v|
      $archon_redis.hset("archon_available_tasks", k, v)
    end
  end
end
