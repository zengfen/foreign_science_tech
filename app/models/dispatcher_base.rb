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

    # $archon_redis.keys("archon_task_total_results_*").each do |k|
    #   puts k
    #   id = k.gsub("archon_task_total_results_", "")
    #   spider_task = SpiderTask.find_by_id(id)
    #   next if spider_task.blank?

    #   $archon_redis.zrange("archon_task_total_results_#{id}", 0, -1, withscores: true).each do |kk, vv|
    #     DispatcherTaskResultCounter.create(task_id: id.to_i, ip: "", hour: Time.parse("#{kk}0000"), result_count: vv.to_i)
    #   end
    # end

    # {
    #   1 => 'discard_count', # 失败任务
    #   2 => 'completed_count', # 成功任务
    #   3 => 'runing_count', # 执行中任务
    #   4 => 'data_count', # 数据量
    #   5 => 'receiver_count', # 写入kafka数据量
    #   6 => 'loader_consumer_count', # kafka消费数量
    #   7 => 'loader_load_count', # 写入ES数量
    #   # 8 => 'host_task_counters' # 主机完成的任务量
    # }

    data = {}
    StatisticalInfo.select('host_ip, info_type, count, hour_field').where('count != 0').each do |x|
      ts = Time.parse(x.hour_field + '0000').to_i
      next if x.host_ip.blank?

      kk = "#{x.host_ip.strip}_#{x.hour_field}"
      data[kk] ||= {
        ip: x.host_ip.strip,
        hour: ts,
        task_count: 0,
        discard_count: 0,
        completed_count: 0,
        result_count: 0,
        left_result_count: 0,
        receiver_result_count: 0,
        loader_consume_count: 0,
        loader_load_count: 0,
        dumper_task_count: 0,
        dumper_result_count: 0
      }

      case x.info_type
      when 1
        data[kk][:task_count] += x.count
        data[kk][:discard_count] += x.count
      when 2
        data[kk][:task_count] += x.count
        data[kk][:completed_count] += x.count
      when 4
        data[kk][:result_count] += x.count
      when 5
        data[kk][:receiver_result_count] += x.count
      when 6
        data[kk][:loader_consume_count] += x.count
      when 7
        data[k][:loader_load_count] += x.count
      end
    end

    data.each do |k, v|
      DispatcherHostTaskCounter.create(v)
    end

    nil
  end
end
