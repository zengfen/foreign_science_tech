class HostsController < ApplicationController
  before_action :logged_in_user
  def index
   opts = {}
   opts[:extranet_ip] = params[:keyword] unless params[:keyword].blank?
   @hosts =  Host.multi_services(params[:services]).where(opts).order("created_at desc").page(params[:page]).per(10)
  end


  def index_bak
    hosts = $archon_redis.hgetall('archon_hosts')
    @hosts = []

    hosts.each do |k, v|
      c = $geo_ip.country(k)
      country = c.country_code2 == 'CN' ? '国内' : '国外'
      service_count = $archon_redis.hlen("archon_host_services_#{k}")

      running_service_count = $archon_redis.hgetall("archon_host_services_#{k}").count { |_m, n| n == 'true' }

      # 心跳间隔潮所1分钟，所有的状态修改为未知
      @hosts << [k, country, Time.at(v.to_i), service_count, running_service_count]
    end
  end

  def show
    @ip = params[:ip]
    # 心跳间隔潮所1分钟，所有的状态修改为未知
    @heartbeat_at = Time.at($archon_redis.hget('archon_hosts', @ip).to_i)
    c = $geo_ip.country(@ip)
    @country = c.country_code2 == 'CN' ? '国内' : '国外'
    @services = $archon_redis.hgetall("archon_host_services_#{@ip}")
  end
end
