class SocialAccountMonitorsController < ApplicationController
  before_action :logged_in_user
  before_action :test_account,only: %i[create create_accounts delete_account]
  def index
    @monitor = SocialAccountMonitor.new
    @spiders = Spider.select('id, spider_name').order('created_at desc').collect { |x| [x.spider_name, x.id] }
    @monitors = SocialAccountMonitor.all
  end

  def create
    SocialAccountMonitor.create_or_update!(params)
    flash['success'] = '设置成功'

    redirect_to(action: :index)
  end

  def show
    monitor = SocialAccountMonitor.find(params[:id])

    key = "archon_monitor_#{monitor.account_type}"
    @accounts = $archon_redis.hgetall(key)
  end

  def delete_account
    monitor = SocialAccountMonitor.find(params[:id])

    key = "archon_monitor_#{monitor.account_type}"

    $archon_redis.hdel(key, params[:account])

    redirect_to(action: :index)
  end

  def create_accounts
    monitor = SocialAccountMonitor.find(params[:id])
    monitor.monitor_accounts(params.split("\n"))

    render json: { type: 'success', message: '成功！' }
  end
end
