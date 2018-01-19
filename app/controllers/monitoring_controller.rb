class MonitoringController < ApplicationController
  def lucene
    body = RestClient.get("http://10.27.3.39:9200/_cluster/health?pretty=true").body
    @cluster = JSON.parse(body)
    @nodes =  JSON.parse(RestClient.get("http://10.27.3.39:9200/_nodes/stats/fs,jvm,http,process?human&pretty&pretty").body)


    opts = {}
    opts[:category] = params[:category] if  !params[:category].blank?
    opts[:spider_name] = params[:keyword] if !params[:keyword].blank?
    @spiders = Spider.where(opts).order("created_at desc").page(params[:page]).per(10)
    @spider = Spider.new
  end
end
