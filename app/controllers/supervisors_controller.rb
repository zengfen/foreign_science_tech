class SupervisorsController < ApplicationController

  def index
    service_name = 'supervisor'
    @agents = []
    $archon_redis.keys('archon_host_services_*').each do |key|
      status = $archon_redis.hget(key, service_name)
      next if status.blank?
      ip = key.gsub('archon_host_services_', '')
      heartbeat_at = $archon_redis.hget('archon_hosts', ip).to_i
      c = $geo_ip.country(ip)
      country = c.country_code2 == 'CN' ? '国内' : '国外'
      @agents << [ip, country,  heartbeat_at, Host.get_status(heartbeat_at, status)]
    end
  end

end