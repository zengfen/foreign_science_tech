class InformationStatisticsController < ApplicationController
  before_action :logged_in_user

  def index
  	opt = {}
  	@countries = InformationExcel.new.countries_json
  	@data_sources = MediaInfo.data_sources 
  	@levels = MediaInfo.levels
  	a = InformationStatistics.new
  	@redis_key = a.redis_key
  	@day = 0
  	@lists = MediaInfo.where(opt).page(params[:page]).per(20)
  end

  def govern
  	opt = {}
  	@countries = InformationExcel.new.countries_json
  	@data_sources = GovernmentInfo.data_sources
  	@levels = GovernmentInfo.levels
  	a = InformationStatistics.new
  	@redis_key = a.redis_key
  	@day = 0
  	@lists = GovernmentInfo.where(opt).page(params[:page]).per(20)  	
  	return render 'index'
  end
end