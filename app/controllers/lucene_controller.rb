class LuceneController < ApplicationController
  def index

    link = "http://10.27.3.39:9200/_cat/indices/#{Spider.categories.values.collect{|x| "*#{x}*"}.join(",")}?format=json&pretty&s=docs.count:desc"
    if !params[:category].blank? || !params[:keyword].blank?
      key = params[:category].blank? ? params[:keyword] : params[:category]
      link = "http://10.27.3.39:9200/_cat/indices/*#{key}*?format=json&pretty&s=docs.count:desc"
    end
    Rails.logger.info(link)
    body = RestClient.get(link).body
    indices = JSON.parse(body)
    @indices = Kaminari.paginate_array(indices, total_count: indices.count).page(params[:page]).per(100)

  end

  def create_index
    yms = (Date.parse(params[:begin_time]+"-01")..Date.parse(params[:end_time]+"-01")).map{|d| "#{d.year}#{d.month.to_s.length==1 ? "0"+d.month.to_s : d.month.to_s}"}.uniq
    if params[:category].blank?
      render :json=>"category is null"
      return
    end
    Spider.create_index(params[:category],yms)
    redirect_to "/lucene/index"
  end

end
