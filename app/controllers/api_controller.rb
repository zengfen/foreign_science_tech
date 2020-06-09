class ApiController < ApplicationController

  # 爬虫状态查询接口
  def job_lists
    datas = []
    TSkJobInstance.all.each do |x|
      data_count = TData.where(spider_name:x.spider_name).count
      log_spider_ids = TLogSpider.where(spider_name:x.spider_name).pluck(:log_spider_id)
      error_count = Subtask.where(log_spider_id:log_spider_ids,status:Subtask::TypeSubtaskError).count
      datas << x.attributes.merge({data_count:data_count,error_count:error_count})
    end
    render json: { datas: datas }
    # TData 是否支持实时查询
    # 报警信息 是指所有历史报警数量吗
    #爬虫状态查询需要为前端提供接口，该功能实时返回所有爬虫名称、状态、爬取总量、报警信息。
  end
  
  # 实时启动任务
  def start_task
    spider_name = params[:spider_name]
    spider = Spider.where(spider_name:spider_name).first
    if spider.blank?
      res = {type:"error",message:"找不到对应的爬虫"}
      return render json: res
    end
    res,spider_task = spider.create_spider_task(SpiderTask::RealTimeTask)
    if res[:type] == "error"
      return render json: res
    end
    res = spider_task.start_task
    render json: res
  end

  # 暂停任务
  def stop_task
    spider_name = params[:spider_name]
    spider = Spider.where(spider_name:spider_name).first
    if spider.blank?
      res = {type:"error",message:"找不到对应的爬虫"}
      return render json: res
    end
    spider_task = spider.spider_tasks.where(status:SpiderTask::RealTimeTask).order(:created_at).last
    if spider_task.blank?
      res = {type:"error",message:"找不到对应的任务"}
      return render json: res
    end
    res = spider_task.stop_task
    if res[:type] == "error"
      return render json: res
    end
  end


end


