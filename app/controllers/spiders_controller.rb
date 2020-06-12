class SpidersController < ApplicationController
  before_action :logged_in_user
  before_action :get_spider, only: %i[show show_info load_edit_form update destroy start stop start_cycle_task stop_cycle_task]

  def index
    opts = {}
    opts[:spider_name] = params[:spider_name] unless params[:spider_name].blank?
    @spiders = Spider.where(opts).order('created_at desc').page(params[:page]).per(20)
    @spider = Spider.new
    @task_info = {}
    TSkJobInstance.all.each do |x|
      @task_info[x.spider_name] = {freq:"1day",next_time:Date.today}
    end
    @total_count = TData.group(:data_spidername).count
  end

  def show
    @spider = Spider.find(params[:id])
  end

  def create
    @spider = Spider.new(spider_params)
    if @spider.save
      # TSkJobInstance.create(spider_name: @spider.spider_name,cron_minutes:1,cron_hour:0,project_id:1)
      flash[:success] = '创建成功'
    else
      flash[:error] = @spider.errors.full_messages.join('\n')
    end
    redirect_to spiders_path
  end

  def load_edit_form

  end

  def update
    if @spider.update(spider_params)
      flash[:success] = '更新成功！'
    else
      flash[:error] = spider.errors.full_messages.join('\n')
    end

    redirect_to spiders_path
  end

  def destroy
    render json: {type: 'success', message: '操作成功！'} if @spider.destroy
  end



  def start_cycle_task
    job_instance = TSkJobInstance.where(spider_name:@spider.spider_name).first
    job_instance.init_instance_job
    day = Date.today.strftime("%F")
    time = job_instance.cron_hour.to_i.to_s + ":" + job_instance.cron_minutes.to_i.to_s
    time = Time.parse("#{day} #{time}")
    next_time = Time.now > time ? time + 1.day : time
    @spider.update(status:1,next_time:next_time)
    render json: {type:"success",message:'周期任务已开启！'}
  end

  def stop_cycle_task
    job_instance = TSkJobInstance.where(spider_name:@spider.spider_name).first
    job_instance.stop_task
    @spider.update(status:2)
    render json: {type:"success",message:'周期任务已停止！'}
  end

  private

  def spider_params
    params.require(:spider).permit(:spider_name,:name_en,:next_time)
  end

  def get_spider
    @spider = Spider.find_by(id: params[:id])
    redirect_to root_path if @spider.blank?
  end
end
