class DataCentersController < ApplicationController
  before_action :logged_in_user

  def index
    params[:search_type] = params[:search_type] || "fuzzy"
    @spiders = Spider.pluck(:spider_name, :name_en)
    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || 20).to_i
    search_cond
    @datas = @datas.order("con_time desc").page(@page).per(@per_page)
  end

  def search_cond
    # 模糊搜索
    if params[:search_type] == "fuzzy"
      keyword = params[:keyword].to_s.strip
      @datas = TData.where("data_time > ?",Time.parse("2020-06-01"))
      if keyword.present?
        @datas = @datas.where("con_title like '%#{keyword}%' or con_text like '%#{keyword}%'")
      end
    else
      # 精确查询
      # con_title con_text  website_name data_spidername con_author con_time
      opts = {}
      opts[:data_spidername] = params[:spider_name].to_s.strip if params[:spider_name].to_s.strip.present?
      opts[:website_name] = params[:website_name].to_s.strip if params[:website_name].to_s.strip.present?
      # opts[:con_author] = params[:con_author].to_s.strip if params[:con_author].to_s.strip.present?
      author_opt = ""
      author_opt = "con_author like '%#{params[:con_author].to_s.strip}%'" if params[:con_author].to_s.strip.present?
      opts[:con_title] = params[:con_title].to_s.strip if params[:con_title].to_s.strip.present?
      start_date = params[:start_date].present? ? params[:start_date] : (Date.today - 1.month)
      end_date = params[:end_date].present? ? params[:end_date] : Time.now
      end_date = end_date.to_time.end_of_day > Time.now ? Time.now : end_date.to_time.end_of_day
      @datas = TData.during_con_time(start_date, end_date).where(opts).where(author_opt)
    end
  end

  def show
    @data = TData.find(params[:id])
  end

  def download_excel
    search_cond
    @datas = @datas.order("con_time desc").limit(500)
    respond_to do |format|
      format.xls
    end
  end

  def download_csv
    search_cond
    @datas = @datas.order("con_time desc").limit(500)
    respond_to do |format|
      format.html
      format.csv { send_data @datas.to_csv }
    end
  end

  def download_txt
    search_cond
    @datas = @datas.order("con_time desc").limit(500)
    data = @datas.map{|x| x.attributes.reject{|k,v| k=="data_snapshot_path" }.to_json}.join("\n")
    send_data( data,:type => "txt",:disposition => "attachment", :filename => "download_txt.txt" )
  end
end