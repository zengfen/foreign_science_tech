#sidekiq 配置
require 'sidekiq'
redis_options = Setting.redis.deep_symbolize_keys
Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{redis_options[:host]}:#{redis_options[:port]}/#{redis_options[:db]}",password: redis_options[:password], namespace: 'archon_center_sidekiq' }
end
Sidekiq.configure_client do |config|
   config.redis = { url: "redis://#{redis_options[:host]}:#{redis_options[:port]}/#{redis_options[:db]}",password: redis_options[:password], namespace: 'archon_center_sidekiq' }
end