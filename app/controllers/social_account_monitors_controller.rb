class SocialAccountMonitorsController < ApplicationController
  def index
    @monitor = SocialAccountMonitor.new
    @spiders = Spider.select('id, spider_name').order('created_at desc').collect { |x| [x.spider_name, x.id] }
  end

  def create
    Account.create_or_update!(params)
    flash['success'] = '设置成功'

    redirect_back(action: :index)
  end
end
