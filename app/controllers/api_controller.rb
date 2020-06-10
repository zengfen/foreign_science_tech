class ApiController < ApplicationController

  # 爬虫状态查询接口
  def job_lists
    datas = []
    count = TData.group(:data_spidername).count
    TSkJobInstance.all.each do |x|
      data_count = count[x.spider_name]
      spider = Spider.where(spider_name: x.spider_name).first
      task_ids = spider.spider_tasks.pluck(:id)
      error_count = Subtask.where(task_id: task_ids, status: Subtask::TypeSubtaskError).count
      datas << {spider_name: x.spider_name, status: spider.status_cn, data_count: data_count, error_count: error_count}
    end
    render json: {datas: datas}
    # TData 是否支持实时查询
    # 报警信息 是指所有历史报警数量吗
    #爬虫状态查询需要为前端提供接口，该功能实时返回所有爬虫名称、状态、爬取总量、报警信息。
  end

  # 实时启动任务
  def start_task
    spider_name = params[:spider_name]
    spider = Spider.where(spider_name: spider_name).first
    if spider.blank?
      res = {type: "error", message: "找不到对应的爬虫"}
      return render json: res
    end
    res, spider_task = spider.create_spider_task(SpiderTask::RealTimeTask)
    if res[:type] == "error"
      return render json: res
    end
    res = spider_task.start_task
    render json: res.merge({task_id:spider_task.id})
  end

  # 停止任务
  def stop_task
    task_id = params[:task_id]
    spider_task = SpiderTask.where(id: task_id).first
    if spider_task.blank?
      return render json: {type: "error", message: "找不到对应的任务"}
    end
    if spider_task.destroy
      return render json: {type: "success", message: "任务停止成功"}
    else
      res = {type: "error", message: spider_task.errors.full_messages.join('\n')}
      return render json: res
    end
  end


end


