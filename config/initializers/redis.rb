require 'redis'
require 'redis-namespace'



begin
  #redis_options = Setting.redis.deep_symbolize_keys
  # $redis = Redis.new(:host => redis_options[:host], :port => redis_options[:port], :db => redis_options[:db], :password=>redis_options[:password])
rescue Exception => e
  puts e
end

