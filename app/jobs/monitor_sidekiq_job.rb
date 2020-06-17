class MonitorSidekiqJob < ApplicationJob
  queue_as :monitor_sidekiq

  def perform(*args)

    redis_connection = $redis
    # namespace 根据需要改写
    namespaced_redis = Redis::Namespace.new('foreign_science_tech', redis: redis_connection)
    pipe1_res = namespaced_redis.pipelined do
      namespaced_redis.zcard('schedule'.freeze)
      namespaced_redis.zcard('retry'.freeze)
      namespaced_redis.smembers('processes'.freeze)
      namespaced_redis.smembers('queues'.freeze)
    end

    pipe2_res = namespaced_redis.pipelined do
      pipe1_res[2].each { |key| namespaced_redis.hget(key, 'busy'.freeze) }
      pipe1_res[3].each { |queue| namespaced_redis.llen("queue:#{queue}") }
    end

    s = pipe1_res[2].size
    workers_size = pipe2_res[0...s].map(&:to_i).inject(0, &:+)
    enqueued = pipe2_res[s..-1].map(&:to_i).inject(0, &:+)

    stats = {
      scheduled_size: pipe1_res[0],
      retry_size: pipe1_res[1],
      busy_size: workers_size,
      enqueued_size: enqueued
    }

    stats.each do |stat, value|
      puts "#{stat}: #{value}"
    end
    if stats[:scheduled_size] == 0 && stats[:busy_size] == 0 && stats[:enqueued_size] == 0 && SpiderTask.where(status:[SpiderTask::TypeTaskStart,SpiderTask::TypeTaskReopen]).present?
      # 根据需要重启
      `bash ./stop_sidekiq.sh`
      `bash ./start_sidekiq.sh`
      SpiderTask.where(status:[SpiderTask::TypeTaskStart,SpiderTask::TypeTaskReopen]).each do |spider_task|
        puts "==uncompleted_spider_task_id====#{spider_task.id}="
        spider_task.process_status
      end
    end


  end
end

