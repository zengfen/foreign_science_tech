class LuceneController < ApplicationController
  def index
    body = RestClient.get("http://10.27.3.39:9200/_cluster/health?pretty=true").body
    @cluster = JSON.parse(body)
    opts = {}
    opts[:category] = params[:category] if  !params[:category].blank?
    opts[:spider_name] = params[:keyword] if !params[:keyword].blank?
    @spiders = Spider.where(opts).order("created_at desc").page(params[:page]).per(10)
    @spider = Spider.new
  end
end
