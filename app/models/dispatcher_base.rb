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

    # Account.all.each do |x|
    #   DispatcherAccount.create(id: x.id, content: x.content, valid_time: x.valid_time.to_i)
    # end

    # {
    #   '47.98.243.99' => true,
    #   '47.96.70.15' => true,
    #   '47.88.35.212' => false,
    #   '47.96.68.127' => true,
    #   '47.89.234.131' => true
    # }.each do |k, v|
    #   DispatcherHost.create(:ip => k, :is_internal => v)
    # end

    # $archon_redis.keys("archon_task_details_*").each do |k|
    #   puts k
    #   id = k.gsub("archon_task_details_", "")
    #   spider_task = SpiderTask.find_by_id(id)
    #   next if spider_task.blank?

    #   $archon_redis.hgetall(k).each do |kk, vv|
    #     content = JSON.parse(vv)
    #     DispatcherSubtask.create(id: kk, task_id: content["task_id"], content: content, retry_count: 0)
    #     DispatcherSubtaskStatus.create(id: kk, task_id: content["task_id"], status: 1, created_at: Time.now.to_i)
    #   end
    # end

    $archon_redis.keys("archon_task_total_results_*").each do |k|
      puts k
      id = k.gsub("archon_task_total_results_", "")
      spider_task = SpiderTask.find_by_id(id)
      next if spider_task.blank?

      $archon_redis.zrange("archon_task_total_results_#{id}", 0, -1, withscores: true).each do |kk, vv|
        DispatcherTaskResultCounter.create(task_id: id.to_i, ip: "", hour: Time.parse("#{kk}0000"), result_count: vv.to_i)
      end
    end
  end
end
