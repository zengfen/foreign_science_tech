class DataCentersController < ApplicationController

  def index
    @results = ArchonBase.table_metas
  end


  def show
    table_name = params[:id]

    @results = eval((table_name + "_tag").camelize)

    if table_name == "archon_facebook_post"
      @results = @results.includes(table_name => :user).page(10).per(10)
    elsif table_name == "archon_facebook_comment"
      @results = @results.includes(table_name => :user).page(10).per(10)
    elsif table_name == "archon_twitter" || table_name == "archon_weibo"
      @results = @results.includes(table_name => [:user, :retweet_user]).page(10).per(10)
    else
      @results = @results.includes(table_name).page(10).per(10)
    end
  end

end
