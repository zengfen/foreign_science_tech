class MediaAccountsController < ApplicationController
  before_action :logged_in_user

  def index
  	client = EsConnect.client
  	@options = MediaAccount.get_aggs_opts
  	@media_accounts = MediaAccount.order("created_at asc").page(params[:page]).per(20)
  end

  def test
  	client = EsConnect.client
  	@options = MediaAccount.get_aggs_opts
  	@media_accounts = MediaAccount.order("created_at asc").page(params[:page]).per(20)
  end

  def search
    page = (params[:page] || 1).to_i
  	client = EsConnect.client
  	@options = MediaAccount.get_aggs_opts
  	must_opts = []
  	must_opts<< {term:{fmt: params[:fmt]}} unless params[:fmt].blank?
  	must_opts<< {term:{slg: params[:slg]}} unless params[:slg].blank?
  	must_opts<< {query_string:{fields:["name"],query:params[:keyword]}} unless params[:keyword].blank?
  	res = client.search index:"media_accounts",body:{
  		  	 size: 20,
           from: page - 1,
           query:{ bool:{must:must_opts}},                                       
           sort: {data_id: {order: "asc" }}
        }
    total_count = res["hits"]["total"]
  	datas = res["hits"]["hits"].collect{|x| Hashie::Mash.new(x["_source"])} rescue []
  	@media_accounts = Kaminari.paginate_array(datas, total_count: total_count).page(params[:page]).per(20)
  	render :index
  end

end
