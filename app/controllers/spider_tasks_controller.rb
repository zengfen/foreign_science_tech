class SpiderTasksController < ApplicationController
  before_action :logged_in_user
  before_action :get_spider_task, only: %i[destroy start_task stop_task]


  def index
    @spider_task = SpiderTask.new
    opts = {}
    unless params[:id].blank?
      opts[:id] = params[:id].split(',')
    end
    opts[:spider_id] = params[:spider_id] unless params[:spider_id].blank?
    opts[:status] = params[:status] unless params[:status].blank?
    opts[:task_type] = params[:task_type] unless params[:task_type].blank?
    start_date = params[:start_date].present? ? params[:start_date] : (Date.today - 1.month)
    end_date = params[:end_date].present? ? params[:end_date] : Time.now
    end_date = end_date.to_time.end_of_day > Time.now ? Time.now : end_date.to_time.end_of_day
    @spider_tasks = SpiderTask.includes('spider').where(opts).during(start_date, end_date).order("created_at desc").page(params[:page]).per(20)
  end


  def fail_tasks
    spider_task = Spider.where(id:params[:id]).first.spider_tasks.order(:created_at).last.id rescue nil
    @fail_tasks = Subtask.where(task_id: spider_task, status: Subtask::TypeSubtaskError).page(params[:page]).per(20)
  end

  def create
    spider_id = spider_task_params[:spider_id]
    spider = Spider.find(spider_id) rescue nil
    if spider.blank?
      res = {type:"error",message:"请选择爬虫模板"}
    else
      res = spider.create_spider_task(SpiderTask::RealTimeTask)
    end
    flash[res[:type]] = res[:message]
    redirect_to spider_tasks_path
  end

  def destroy
    render json: {type: 'success', message: '操作成功！'} if @spider_task.destroy
  end

  def start_task
    res = @spider_task.start_task
    render json: res
  end

  def stop_task
    res = @spider_task.stop_task
    render json: res
  end


  private

  def spider_task_params
    params.require(:spider_task).permit(:spider_id,:status,:task_type)
  end

  def get_spider_task
    @spider_task = SpiderTask.find_by(id: params[:id])
    redirect_back(fallback_location: root_path) if @spider_task.blank?
  end
end
