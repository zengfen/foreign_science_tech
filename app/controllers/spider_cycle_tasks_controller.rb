class SpiderCycleTasksController < ApplicationController
	before_action :get_spider

  def index
		opts = {}
    opts[:special_tag] = params[:keyword] if !params[:keyword].blank?
		@spider_tasks = @spider.spider_tasks.where(opts).order("created_at desc").page(params[:page]).per(10)
		@spider_cycle_task = SpiderCycleTask.new
  end

  def new
  	@spider_cycle_task = SpiderCycleTask.new
  end

  def show

  end

  def create
  	@spider_cycle_task = SpiderCycleTask.new(spider_task_params)
	  message = 	@spider_cycle_task.save_with_spilt_keywords
	  flash[message.keys.first.to_sym] = message.values.first

  	redirect_to spider_spider_cycle_tasks_path(@spider)
  end


  def start
    @spider_cycle_task = SpiderCycleTask.find_by(id: params[:id])
    @spider_cycle_task.task_job_run!

    redirect_to spider_spider_cycle_tasks_path(@spider)
  end


  def stop
    @spider_cycle_task = SpiderCycleTask.find_by(id: params[:id])
    @spider_cycle_task.destroy_job!

    redirect_to spider_spider_cycle_tasks_path(@spider)
  end


  private
  def spider_cycle_task_params
  		params.require(:spider_cycle_task).permit(:spider_id,:special_tag, :level, :keyword,:period)
  end

  def get_spider
  	 @spider = Spider.find_by(id: params[:spider_id])
  	 redirect_to(root_url) if  @spider.blank?
  end
end
