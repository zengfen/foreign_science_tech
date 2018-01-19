class LuceneController < ApplicationController
  def index
    opts = {}
    opts[:category] = params[:category] if  !params[:category].blank?
    opts[:spider_name] = params[:keyword] if !params[:keyword].blank?
    @spiders = Spider.where(opts).order("created_at desc").page(params[:page]).per(10)
    @spider = Spider.new
  end
end
