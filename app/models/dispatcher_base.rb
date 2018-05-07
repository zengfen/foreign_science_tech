class DispatcherBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection DispatcherDB


  def self.migrate_data
    # data = {}
    # $archon_redis.smembers("archon_available_tasks").each do |x|
    #   data[x] =  SpiderTask.find(x).max_retry_count
    # end

    # puts data
    # $archon_redis.del("archon_available_tasks")

    # data.each do |k, v|
    #   $archon_redis.hset("archon_available_tasks", k, v)
    # end


    Account.all.each do |x|
      DispatcherAccount.create(id: x.id, content: x.content, valid_time: x.valid_time.to_i)
    end
  end
end
