class SocialAccountMonitorsController < ApplicationController

  def index
    @monitor = SocialAccountMonitor.new
    @spiders = Spider.select("id, name").collect{|x| [x.name, x.id]}
  end

end
