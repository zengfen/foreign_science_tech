class LuceneController < ApplicationController
  def index
    body = RestClient.get("http://10.27.3.39:9200/_cat/indices?format=json&pretty").body
    indices = JSON.parse(body)
    @indices = Kaminari.paginate_array(indices, total_count: indices.count).page(params[:page]).per(50)
    opts = {}
    opts[:category] = params[:category] if  !params[:category].blank?
    opts[:spider_name] = params[:keyword] if !params[:keyword].blank?
    @spiders = Spider.where(opts).order("created_at desc").page(params[:page]).per(10)
    @spider = Spider.new
  end
end
