class SocialAccountMonitorsController < ApplicationController

  def index
    @monitor = SocialAccountMonitor.new
    @spiders = Spider.select("id, spider_name").collect{|x| [x.spider_name, x.id]}
  end

end
