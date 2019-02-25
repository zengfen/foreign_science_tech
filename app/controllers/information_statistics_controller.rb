class InformationStatisticsController < ApplicationController
  before_action :logged_in_user

  def index
  	@countries = InformationExcel.new.countries_json
  	@data_sources = MediaInfo.data_sources 
  	@levels = MediaInfo.levels
		@hav_infos = MediaInfo.hav_infos
		@custom_domains = MediaInfo.custom_domains
    search(params,MediaInfo)
    if request.xhr?
     return render "_list_body.html.erb", layout: false
    end
	end

  def govern
  	@countries = InformationExcel.new.countries_json
  	@data_sources = GovernmentInfo.data_sources
  	@levels = GovernmentInfo.levels
		@hav_infos = GovernmentInfo.hav_infos
		@custom_domains = MediaInfo.custom_domains
    search(params,GovernmentInfo)
    if request.xhr?
     return render "_list_body.html.erb", layout: false
    end

  	return render 'index'
	end

  def detail
    model = params[:model]
    id = params[:id]
    if model.blank?
      flash['error'] = "数据类型不能为空"
      return redirect_to information_statistics_path
    end
    if id.blank?
      flash['error'] = "数据ID不能为空"
      return redirect_to information_statistics_path      
    end
    k = Object.const_get model
    @data = k.where({id:id}).first
    if @data.blank?
      flash['error'] = '该数据不存在或已被删除'
      return redirect_to information_statistics_path
    end
    @data_sources = MediaInfo.data_sources
    @levels = MediaInfo.levels
    @countries = InformationExcel.new.countries_json
    @domain_data_source = DomainDataSource.where({domain:@data.domain}).first
  end

	def all_info
  	@countries = InformationExcel.new.countries_json
  	@data_sources = MediaInfo.data_sources 
  	@levels = MediaInfo.levels
		@hav_infos = MediaInfo.hav_infos
    search(params,'')
    return render 'index'		
	end

  def update_statistic
    InformationStatistics.start_renew
		UpdateInformationStatisticsJob.perform_later
    flash['success'] = "更新计算后台运行开始"
		redirect_to information_statistics_path
  end

  def update_today_statistic
    InformationStatistics.start_renew1
    UpdateTodayInformationStatisticsJob.perform_later
    flash['success'] = "更新计算后台运行开始"
    redirect_to information_statistics_path    
  end

  def search(params,model)
    opt = {}
    custom_domains = MediaInfo.custom_domains
    a = InformationStatistics.new
    @redis_key = a.redis_key
    source_opt =  params[:data_source].present? ? "data_source like '%#{params[:data_source]}%'" : {}
    opt[:country_code] = params[:country_code] if params[:country_code].present?
    # opt[:level] = params[:level] if params[:level].present?
    level_opt = params[:level].present? ? "level like '%#{params[:level]}%'" : {}
    opt[:hav_infos] = params[:hav_infos] if params[:hav_infos].present?
    opt[:domain] = custom_domains[params[:custom_domains]] if params[:custom_domains].present?
    name_domain_opt = params[:keyword].present? ? "ch_name like '%#{params[:keyword]}%' or domain like '%#{params[:keyword]}%'" : {}
    lists = []
    if model.blank?
    	lists += MediaInfo.where(opt).where(source_opt).to_a
    	lists += GovernmentInfo.where(opt).where(source_opt).to_a
    else
    	lists = model.where(opt).where(source_opt).where(level_opt).where(name_domain_opt)
    end
    info_count = {}
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
    lists.each do |obj|
      info_count[obj.id] ||= 0
      # ((Date.today - end_date).to_i..(Date.today - start_date).to_i).each do |day|
      #   info_count[obj.id] += $redis.hget(@redis_key,"#{obj.domain}_#{day}").to_i
      # end
      (start_date..end_date).each do |day|
        info_count[obj.id] += $redis.hget(@redis_key,"#{obj.domain}_#{day.strftime("%F")}").to_i
      end
    end
    min_count = params[:min_count].present? ? params[:min_count].to_i : 0
    # 按照最小值和最大值筛选并排序
    @info_count = info_count.select{|k,v| params[:max_count].present? ? (v >= min_count && v <= params[:max_count].to_i) : (v >= min_count)}.sort_by{|k,v| v}.reverse.to_h
    page = (params[:page] || 1).to_i
    per_page = (params[:per] || 50).to_i
    start_index = (page - 1)*per_page
    end_index = start_index + per_page
    ids = @info_count.keys[start_index...end_index]
    lists = ids.present? ? lists.where(id:ids).order("find_in_set(id, '#{ids.join(",")}')") : []
    @lists = Kaminari.paginate_array(lists, total_count: @info_count.count).page(page).per(per_page)
  end

  def switch_status
    status = ''
    if params[:type] == 'today'
      status = InformationStatistics.switch1
    else
      status = InformationStatistics.switch
    end
    return render json:{status:status}
  end

  def remark
    model = params[:model]
    id = params[:id]
    if model.blank?
      return render json:{type:'error',message:'数据类型不能为空'}
    end
    if id.blank?
      return render json:{type:'error',message:'数据ID不能为空'}
    end
    k = Object.const_get model
    data = k.where({id:id}).first
    if data.blank?
      return render json: {type:'error',message:'该数据不存在或已被删除'}
    end
    data.update({remark:params[:remark]})
    return render json: {type:'success',message:'数据更新成功'}
  end

  def hav_infos
    model = params[:model]
    id = params[:id]
    if model.blank?
      return render json:{type:'error',message:'数据类型不能为空'}
    end
    if id.blank?
      return render json:{type:'error',message:'数据ID不能为空'}
    end
    k = Object.const_get model
    data = k.where({id:id}).first
    if data.blank?
      return render json: {type:'error',message:'该数据不存在或已被删除'}
    end
    data.update({hav_infos:params[:hav_infos],remark:params[:remark]})
    return render json: {type:'success',message:'数据更新成功'}    
  end

  def update_data_source
    model = params[:model]
    id = params[:id]
    if model.blank?
      return render json:{type:'error',message:'数据类型不能为空'}
    end
    if id.blank?
      return render json:{type:'error',message:'数据ID不能为空'}
    end
    k = Object.const_get model
    data = k.where({id:id}).first
    if data.blank?
      return render json: {type:'error',message:'该数据不存在或已被删除'}
    end    
    data_source = params[:data_source].join(',') rescue ''
    data.update({data_source:data_source})
    return render json: {type:'success',message:'数据源更新成功'}
  end

  # 下载每日新闻量
  def download_daily_news_count
    opt = {}
    source_opt =  params[:data_source].present? ? "data_source like '%#{params[:data_source]}%'" : {}
    opt[:country_code] = params[:country_code] if params[:country_code].present?
    # opt[:level] = params[:level] if params[:level].present?
    level_opt = params[:level].present? ? "level like '%#{params[:level]}%'" : {}
    opt[:hav_infos] = params[:hav_infos] if params[:hav_infos].present?
    opt[:domain] = custom_domains[params[:custom_domains]] if params[:custom_domains].present?
    name_domain_opt = params[:keyword].present? ? "ch_name like '%#{params[:keyword]}%' or domain like '%#{params[:keyword]}%'" : {}    
    
    model = Object.const_get params[:model] 
    lists = model.where(opt).where(source_opt).where(level_opt).where(name_domain_opt)
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.today
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
    info_count = {}
    lists.each do |obj|
      info_count[obj.id] ||= 0
      # ((Date.today - end_date).to_i..(Date.today - start_date).to_i).each do |day|
      #   info_count[obj.id] += $redis.hget(@redis_key,"#{obj.domain}_#{day}").to_i
      # end
      (start_date..end_date).each do |day|
        info_count[obj.id] += $redis.hget(@redis_key,"#{obj.domain}_#{day.strftime("%F")}").to_i
      end
    end
    min_count = params[:min_count].present? ? params[:min_count].to_i : 0
    @info_count = info_count.select{|k,v| params[:max_count].present? ? (v >= min_count && v <= params[:max_count].to_i) : (v >= min_count)}.sort_by{|k,v| v}.reverse.to_h
    ids = @info_count.keys

    filename = "#{Time.now}_.xlsx"
    file_path = Rails.root.to_s + "/public/download/#{filename}"
    workbook  = WriteXLSX.new(file_path)
    worksheet = workbook.add_worksheet('Sheet1')
    worksheet.set_column(0, 0, 40)
    worksheet.set_column(1, 1, 25)
    worksheet.set_column(2, 2, 25)
    xlsx_format = workbook.add_format(
      :size  => 10,
      :border => 1
      )
    xlsx_format.set_align('left')

    i = 0
    lists.where({id:ids}).each do |x|
      (start_date..end_date).each do |day|
        count = $redis.hget(@redis_key,"#{x.domain}_#{day.strftime("%F")}").to_i
        date = day.strftime("%F")
        worksheet.write(i,0,x.ch_name,xlsx_format)
        worksheet.write(i,1,date,xlsx_format)
        worksheet.write(i,2,count,xlsx_format)
        i += 1
      end      
    end

    send_file(file_path, :type => 'xlsx', :disposition => 'attachment', :filename => filename)
  end

end