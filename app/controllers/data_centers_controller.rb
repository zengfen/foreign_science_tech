class DataCentersController < ApplicationController

  def index
    @results = ArchonBase.table_metas
  end


  def show
    table_name = params[:id]

    @results = eval((table_name + "_tag").camelize)

    if table_name == "archon_facebook_post"
      @results = @results.includes(record: :user)
    elsif table_name == "archon_facebook_comment"
      @results = @results.includes(record:  :user)
    elsif table_name == "archon_twitter" || table_name == "archon_weibo"
      @results = @results.includes(record: [:user, :retweet_user])
    else
      @results = @results.includes(:record)
    end

    @results = @results.page(params[:page]).per(20)
  end

end
