class SpiderCycleTasksController < ApplicationController
	before_action :logged_in_user
	before_action :get_spider

  def show

  end

  def create
  	@spider_cycle_task = SpiderCycleTask.new(spider_cycle_task_params)
	  message = 	@spider_cycle_task.save_with_spilt_keywords
	  flash[message.keys.first.to_sym] = message.values.first

  	redirect_to "/tasks"
  end


  def start
    @spider_cycle_task = SpiderCycleTask.find_by(id: params[:id])
    @spider_cycle_task.task_job_run!

    redirect_to spider_spider_cycle_tasks_path(@spider)
  end


  def stop
    @spider_cycle_task = SpiderCycleTask.find_by(id: params[:id])
    @spider_cycle_task.stop_job!

    redirect_to spider_spider_cycle_tasks_path(@spider)
  end


  private
  def spider_cycle_task_params
  		params.require(:spider_cycle_task).permit(:spider_id,:special_tag, :level, :keyword,:period,:max_retry_count)
  end

  def get_spider
  	 @spider = Spider.find_by(id: params[:spider_id])
  	 redirect_to(root_url) if  @spider.blank?
  end
end
