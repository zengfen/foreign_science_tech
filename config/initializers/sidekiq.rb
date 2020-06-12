# sidekiq 配置
require 'sidekiq'

redis_options = Setting.redis.deep_symbolize_keys
begin
  Sidekiq.configure_server do |config|
    config.redis = { url: "redis://#{redis_options[:host]}:#{redis_options[:port]}/#{redis_options[:db]}", password: redis_options[:password], namespace: 'foreign_science_tech' }

    # 从配置文件中读取定时任务
    schedule_file = 'config/sidekiq_schedule.yml'
    if File.exists?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
    end
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: "redis://#{redis_options[:host]}:#{redis_options[:port]}/#{redis_options[:db]}", password: redis_options[:password], namespace: 'foreign_science_tech' }
  end

rescue Exception => e
  puts e
end
