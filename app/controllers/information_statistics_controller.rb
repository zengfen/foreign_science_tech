class InformationStatisticsController < ApplicationController
  before_action :logged_in_user

  def index
  	opt = {}
  	@countries = InformationExcel.new.countries_json
  	@data_sources = MediaInfo.data_sources 
  	@levels = MediaInfo.levels
		@hav_infos = MediaInfo.hav_infos
  	a = InformationStatistics.new
  	@redis_key = a.redis_key
		source_opt =  params[:data_source].present? ? "data_source like '%#{params[:data_source]}%'" : {}
		opt[:country_code] = params[:country_code] if params[:country_code].present?
		opt[:level] = params[:level] if params[:level].present?
		opt[:hav_infos] = params[:hav_infos] if params[:hav_infos].present?
		@lists = MediaInfo.where(opt).where(source_opt).page(params[:page]).per(20)
		@info_count = {}
		start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today
		end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
		@lists.each do |obj|
			@info_count[obj.id] ||= 0
			((Date.today - end_date).to_i..(Date.today - start_date).to_i).each do |day|
				@info_count[obj.id] += $redis.hget(@redis_key,"#{obj.domain}_#{day}").to_i
			end
		end
  end

  def govern
  	opt = {}
  	@countries = InformationExcel.new.countries_json
  	@data_sources = GovernmentInfo.data_sources
  	@levels = GovernmentInfo.levels
		@hav_infos = GovernmentInfo.hav_infos
		a = InformationStatistics.new
  	@redis_key = a.redis_key
		source_opt =  params[:data_source].present? ? "data_source like '%#{params[:data_source]}%'" : {}
		opt[:country_code] = params[:country_code] if params[:country_code].present?
		opt[:level] = params[:level] if params[:level].present?
		opt[:hav_infos] = params[:hav_infos] if params[:hav_infos].present?
		@lists = GovernmentInfo.where(opt).where(source_opt).page(params[:page]).per(20)
		@info_count = {}
		start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today
		end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
		@lists.each do |obj|
			@info_count[obj.id] ||= 0
			((Date.today - end_date).to_i..(Date.today - start_date).to_i).each do |day|
				@info_count[obj.id] += $redis.hget(@redis_key,"#{obj.domain}_#{day}").to_i
			end
		end
  	return render 'index'
	end

  def update_statistic
		UpdateInformationStatisticsJob.perform_later
		flash[:status] = "更新计算后台运行开始"
		redirect_to information_statistics_path
	end

end