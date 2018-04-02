class HostsController < ApplicationController
  before_action :logged_in_user
  def index
    opts = {}
    opts[:extranet_ip] = params[:keyword] unless params[:keyword].blank?
    @hosts = Host.multi_services(params[:services]).where(opts).order('created_at desc').page(params[:page]).per(10)
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

  def service_errors
    @receiver_errors = $archon_redis.hgetall('archon_receiver_errors')
    @comsume_errors = $archon_redis.hgetall('archon_loader_consume_errors')
    @load_errors =  $archon_redis.hgetall('archon_loader_load_errors')
  end

  def service_counters
    # receiver_ips =  $archon_redis.hkeys('archon_receiver_errors')
    # loader_ips = $archon_redis.hkeys('archon_loader_consume_errors')

    # @receiver_data = {}

    # receiver_ips.each do |ip|
    #   key = "archon_receiver_#{ip}_count"

    #   v = $archon_redis.zrange(key, 0, -1, withscores: true).map { |x| x[1] }.sum
    #   @receiver_data[ip] = v.blank? ? 0 : v.to_i
    # end

    # @loader_data = {}

    # loader_ips.each do |ip|
    #   key = "archon_loader_#{ip}_consumer_count"
    #   @loader_data[ip] = []

    #   v = $archon_redis.zrange(key, 0, -1, withscores: true).map { |x| x[1] }.sum
    #   @loader_data[ip] << (v.blank? ? 0 : v.to_i)

    #   key = "archon_loader_#{ip}_load_count"
    #   v = $archon_redis.zrange(key, 0, -1, withscores: true).map { |x| x[1] }.sum
    #   @loader_data[ip] << (v.blank? ? 0 : v.to_i)
    # end
    @receiver_data = {}
    receiver_datas = StatisticalInfo.receiver_datas.group_by(&:host_ip)
    receiver_datas.each do |k,v|
      @receiver_data[k] = v.collect{|x| x.count}.sum rescue 0
    end

    @loader_data = {}
    loader_datas = StatisticalInfo.where(:info_type=>[6,7]).group_by(&:host_ip)
    loader_datas.each do |k,v|
      @loader_data[k] = []
      @loader_data[k] << v.collect{|x| x.info_type==6? x.count : 0}.sum rescue 0
      @loader_data[k] << v.collect{|x| x.info_type==7? x.count : 0}.sum rescue 0
    end

  end

  def receiver_trend
    ip = params[:ip]
    # key = "archon_receiver_#{ip}_count"
    # @results = $archon_redis.zrange(key, 0, -1, :withscores => true).to_h
    @results = StatisticalInfo.receiver_datas.where(:host_ip=>ip).order("hour_field asc").collect{|x| [x.hour_field,x.count]}.to_h
  end

  def loader_kafka_trend
    ip = params[:ip]
    # key = "archon_loader_#{ip}_consumer_count"
    # @results = $archon_redis.zrange(key, 0, -1, :withscores => true).to_h
    @results = StatisticalInfo.loader_consumer_datas.where(:host_ip=>ip).order("hour_field asc").collect{|x| [x.hour_field,x.count]}.to_h
  end

  def loader_es_trend
    ip = params[:ip]
    # key = "archon_loader_#{ip}_load_count"
    # @results = $archon_redis.zrange(key, 0, -1, :withscores => true).to_h
    @results = StatisticalInfo.loader_load_datas.where(:host_ip=>ip).order("hour_field asc").collect{|x| [x.hour_field,x.count]}.to_h
  end


  def host_task_counters
    keys = $archon_redis.keys("archon_host_task_counter_*")


    start_hour = (Time.now - 2.days).at_beginning_of_day
    end_hour = Time.now.at_beginning_of_hour
    @hours = (start_hour.to_i .. end_hour.to_datetime.to_i).step(1.hour).to_a.map{|x| x.strftime("%Y%m%d%H")}
    @results = {}
    keys.each do |k|
      start = start_hour.strftime("%Y%m%d%H")
      ip = k.gsub("archon_host_task_counter_", "")
      res = $archon_redis.zrange(k, 0, -1, withscores: true).select{|x| x[0] >= start}.to_h


      @results[ip] = []
      @hours.each do |x|
        @results[ip] << (res[x] || 0)
      end
    end
  end
end
