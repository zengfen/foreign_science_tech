class HostsController < ApplicationController

  def index
    hosts = $archon_redis.hgetall("host_list")
    agents_status = $archon_redis.hgetall("host_agent_status_list")


    @hosts = []

    hosts.each do |k, v|
      agent_status = agents_status[k]
      c = GeoIP.new('GeoIP.dat').country(k)
      country = c.country_code == "CN" ? "国内" : "国外"

      if agent_status.blank?
        @hosts << [k, country, Time.now.to_i - v.to_i, "未知"]
      elsif agent_status == "true"
        @hosts << [k, country, Time.now.to_i - v.to_i, "运行中"]
      else
        @hosts << [k, country, Time.now.to_i - v.to_i, "停止"]
      end
    end

  end

end
