class LuceneController < ApplicationController
  before_action :logged_in_user
  def index

    link = "http://10.27.3.39:9200/_cat/indices/#{Spider.index_categories.values.collect{|x| "*#{x}*"}.join(",")}?format=json&pretty&s=docs.count:desc"
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
    #Spider.create_index(params[:category],yms)
    ElasticsearchIndex.perform_later(params[:category],yms)
    redirect_to "/lucene/index"
  end

  def reset
    key = params[:id].gsub(/_\d+/,"").to_s
    date = params[:id].match(/_(\d+)/)[1].to_s
    if Spider.index_categories.values.include?(key) || !date.blank?
      key.classify.constantize.recreate_index(date)
    else
      render :json=>"invalid index"
      return
    end
    render json: {type: "success",message:"操作成功！"}
  end

  def remove
    $elastic.indices.delete index:"#{params[:id]}"
    render json: {type: "success",message:"操作成功！"}
  end

  def search
    $elastic = Elasticsearch::Client.new hosts:[{ host: "10.46.226.135",port: "9200",user: "elastic",password: "changeme"},{ host: "10.27.3.39",port: "9200",user: "elastic",password: "changeme"},{ host: "10.28.46.145",port: "9200",user: "elastic",password: "changeme"},{ host: "10.28.46.192",port: "9200",user: "elastic",password: "changeme"}],randomize_hosts: true, log: false,send_get_body_as: "post"

    return render json: {type: "error",message:"请输入索引名称！"} if params[:index_name].blank?
    query_opts = params[:query_opts].blank? ? {} : JSON.parse(params[:query_opts])
    logger.info query_opts
    begin
      response = $elastic.search index: params[:index_name], body: query_opts
      render json:  {type: "success",results:response}
    rescue Exception => e  
      render json:  {type: "error",message: e.message}
    end

  end

  def test

  end

end
