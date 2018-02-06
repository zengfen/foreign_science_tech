class SocialAccountMonitorsController < ApplicationController
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
end
