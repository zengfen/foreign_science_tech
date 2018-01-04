class HostMetricsController < ApplicationController

  def index
  end


  def show
    ip = params[:ip]
    @results = $archon_redis.hgetall("host_metric_#{ip}")
  end

end
