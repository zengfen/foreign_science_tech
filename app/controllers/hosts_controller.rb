class HostsController < ApplicationController
  include ActionView::Helpers::DateHelper
  before_action :logged_in_user
  def index
    hosts = $archon_redis.hgetall('archon_hosts')
    @hosts = []

    hosts.each do |k, v|
      c = $geo_ip.country(k)
      country = c.country_code2 == 'CN' ? '国内' : '国外'
      service_count = $archon_redis.hlen("archon_host_services_#{k}")

      running_service_count = $archon_redis.hgetall("archon_host_services_#{k}").count { |_m, n| n == 'true' }

      @hosts << [k, country, Time.at(v.to_i), service_count, running_service_count]
    end

    # @hosts = []

    # ips = ["101.37.18.60","47.97.44.139","47.97.20.94","101.37.18.174","47.97.9.166","114.55.239.30","114.215.252.18","114.55.239.59","47.97.6.182","118.31.103.172","114.55.31.181","47.96.39.144","118.31.249.35","101.37.163.211","121.196.227.27","101.37.15.82","121.40.193.25","121.40.133.225","121.41.32.223","120.55.113.222","120.26.101.161","121.41.8.233","121.40.171.147","120.26.161.58","121.199.15.141","118.178.132.162","120.55.240.37","120.55.240.53","114.55.41.98","120.27.144.121","118.178.228.245","121.40.114.30","121.40.76.71","121.40.133.188","118.178.143.132","116.62.39.175","118.178.234.147","116.62.38.224","116.62.38.254","118.178.129.33","118.178.89.67","114.55.104.138","114.55.177.186","121.43.156.83","112.124.10.98","114.55.89.170","112.124.2.153","114.55.73.26","114.55.33.232","120.26.132.191","121.199.40.41","121.196.232.223","120.27.160.146","114.55.34.166","114.55.34.43"]
    # ips.each do |ip|
    #  @hosts << [ip, "国内", Time.parse("2018-01-09"), "运行中"]
    # end

    # hosts.each do |k, v|
    #   agent_status = agents_status[k]
    #   c = $geo_ip.country(k)
    #   country = c.country_code2 == "CN" ? "国内" : "国外"

    #   if agent_status.blank?
    #     @hosts << [k, country, Time.at(v.to_i) , "未知"]
    #   elsif agent_status == "true"
    #     @hosts << [k, country, Time.at(v.to_i), "运行中"]
    #   else
    #     @hosts << [k, country, Time.at(v.to_i), "停止"]
    #   end
    # end
  end

  def show
    @ip = params[:ip]
    @heartbeat_at = Time.at($archon_redis.hget('archon_hosts', @ip).to_i)
    c = $geo_ip.country(@ip)
    @country = c.country_code2 == 'CN' ? '国内' : '国外'
    @services = $archon_redis.hgetall("archon_host_services_#{@ip}")
  end
end
