class ReceiversController < ApplicationController

  def index
    @all_receivers = $redis.hgetall("archon_receivers")
    @common_receivers = $redis.zrange("common_receivers_pool", 0, -1, withscores: true)
    @ip_receivers = {}
    ip_receivers_ips  = $redis.keys("ip_receivers_*")
    ip_receivers_ips.each do |ip_key|
      ip = ip_key.gsub("ip_receivers_", "")
      @ip_receivers[ip] = $redis.zrange(ip_key, 0, -1, withscores: true)
    end
  end

end
