class HostsController < ApplicationController
  include ActionView::Helpers::DateHelper

  def index
    hosts = $archon_redis.hgetall("host_list")
    agents_status = $archon_redis.hgetall("host_agent_status_list")


    @hosts = []

    hosts.each do |k, v|
      agent_status = agents_status[k]
      c = $geo_ip.country(k)
      country = c.country_code2 == "CN" ? "国内" : "国外"

      if agent_status.blank?
        @hosts << [k, country, time_ago_in_words(Time.at(v.to_i)) , "未知"]
      elsif agent_status == "true"
        @hosts << [k, country, time_ago_in_words(Time.at(v.to_i)), "运行中"]
      else
        @hosts << [k, country, time_ago_in_words(Time.at(v.to_i)), "停止"]
      end
    end

  end

end
