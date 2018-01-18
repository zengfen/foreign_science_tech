class ReceiversController < ApplicationController
  def index
    @all_receivers = $archon_redis.hgetall('archon_receivers')
    @common_receivers = $archon_redis.zrange('archon_common_receivers_pool', 0, -1, withscores: true)
    @ip_receivers = {}
    ip_receivers_ips = $archon_redis.keys('archon_ip_receivers_*')
    ip_receivers_ips.each do |ip_key|
      ip = ip_key.gsub('archon_ip_receivers_', '')
      @ip_receivers[ip] = $archon_redis.zrange(ip_key, 0, -1, withscores: true)
    end
  end

  def set_common
    # 根据ip 找到配置的域名
    # FIX ME:
    $archon_redis.zadd('archon_common_receivers_pool', 0, "http://archon-receiver.aggso.com")

    redirect_back(fallback_location: {action: "index"})
  end

  def set_agent
    #  选择一组agent hosts
    #
    agent_ip = ''
    $archon_redis.zadd("archon_ip_receivers_#{agent_ip}", 0, params[:ip])

    redirect_back(fallback_location: {action: "index"})
  end
end
