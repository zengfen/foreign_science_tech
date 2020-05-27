# sidekiq 配置
require 'sidekiq'

begin
  Sidekiq.configure_server do |config|
    config.redis = { url: $redis, namespace: 'foreign_science_tech' }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: $redis, namespace: 'foreign_science_tech' }
  end

rescue Exception => e
  puts e
end
