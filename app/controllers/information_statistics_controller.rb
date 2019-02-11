class InformationStatisticsController < ApplicationController
  before_action :logged_in_user

  def index
  	opt = {}
  	@countries = InformationExcel.new.countries_json
  	a = InformationStatistics.new
  	@redis_key = a.redis_key
  	@day = 0
  	@lists = MediaInfo.where(opt).page(params[:page]).per(20)
  end

  def govern
  	
  end
end