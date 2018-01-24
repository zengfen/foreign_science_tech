class HomeController < ApplicationController
  #layout "empty"
  before_action :logged_in_user
  def index

    service_name = 'agent'
    @agents = []
    $archon_redis.keys('archon_host_services_*').each do |key|
      status = $archon_redis.hget(key, service_name)
      next if status.blank?
      ip = key.gsub('archon_host_services_', '')
      @agents << ip
    end
    @agents
    # 求总的把所有的主机的加起来即可。
    # archon_host_discard_counter_101.37.18.174  member: 201812321 score: 459
    #
    # archon_host_completed_counter_101.37.18.174  member: 201812321 score: 459
    #
    # archon_host_task_counter_101.37.18.174  member: 201812321 score: 459
  end
end
