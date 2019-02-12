class InformationStatisticsController < ApplicationController
  before_action :logged_in_user

  def index
  	@countries = InformationExcel.new.countries_json
  	@data_sources = MediaInfo.data_sources 
  	@levels = MediaInfo.levels
		@hav_infos = MediaInfo.hav_infos
		# @lists = MediaInfo.where(opt).where(source_opt).page(params[:page]).per(20)
		# @info_count = {}
		# start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today
		# end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
		# @lists.each do |obj|
		# 	@info_count[obj.id] ||= 0
		# 	((Date.today - end_date).to_i..(Date.today - start_date).to_i).each do |day|
		# 		@info_count[obj.id] += $redis.hget(@redis_key,"#{obj.domain}_#{day}").to_i
		# 	end
		# end
    search(params,MediaInfo)
	end

  def govern
  	@countries = InformationExcel.new.countries_json
  	@data_sources = GovernmentInfo.data_sources
  	@levels = GovernmentInfo.levels
		@hav_infos = GovernmentInfo.hav_infos
    search(params,GovernmentInfo)
  	return render 'index'
	end

  def update_statistic
		UpdateInformationStatisticsJob.perform_later
		flash[:status] = "更新计算后台运行开始"
		redirect_to information_statistics_path
  end

  def search(params,model)
    opt = {}
    a = InformationStatistics.new
    @redis_key = a.redis_key
    source_opt =  params[:data_source].present? ? "data_source like '%#{params[:data_source]}%'" : {}
    opt[:country_code] = params[:country_code] if params[:country_code].present?
    opt[:level] = params[:level] if params[:level].present?
    opt[:hav_infos] = params[:hav_infos] if params[:hav_infos].present?
    lists = model.where(opt).where(source_opt)
    info_count = {}
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
    lists.each do |obj|
      info_count[obj.id] ||= 0
      ((Date.today - end_date).to_i..(Date.today - start_date).to_i).each do |day|
        info_count[obj.id] += $redis.hget(@redis_key,"#{obj.domain}_#{day}").to_i
      end
    end
    min_count = params[:min_count].present? ? params[:min_count].to_i : 0
    # 按照最小值和最大值筛选并排序
    @info_count = info_count.select{|k,v| params[:max_count].present? ? (v >= min_count && v <= params[:max_count].to_i) : (v >= min_count)}.sort_by{|k,v| v}.reverse.to_h
    page = (params[:page] || 1).to_i
    per_page = (params[:per] || 20).to_i
    start_index = (page - 1)*per_page
    end_index = start_index + per_page
    ids = @info_count.keys[start_index...end_index]
    lists = ids.present? ? lists.where(id:ids).order("find_in_set(id, '#{ids.join(",")}')") : []
    @lists = Kaminari.paginate_array(lists, total_count: @info_count.count).page(page).per(per_page)
  end

end