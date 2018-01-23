class SpiderCycleTasksController < ApplicationController
	before_action :logged_in_user
	before_action :get_spider

  def show

  end

  def create
  	@spider_cycle_task = SpiderCycleTask.new(spider_cycle_task_params)
	  message = 	@spider_cycle_task.save_with_spilt_keywords
	  flash[message.keys.first.to_sym] = message.values.first

  	redirect_back(fallback_location:tasks_path)
  end


  def start
    @spider_cycle_task = SpiderCycleTask.find_by(id: params[:id])
    @spider_cycle_task.task_job_run!
    
    render :template => "/tasks/refresh_spider_cycle_task.js.erb", :layout => false
    #redirect_back(fallback_location:tasks_path(:taks_type=>0))
  end


  def stop
    @spider_cycle_task = SpiderCycleTask.find_by(id: params[:id])
    @spider_cycle_task.stop_job!

    render :template => "/tasks/refresh_spider_cycle_task.js.erb", :layout => false
    #redirect_back(fallback_location:tasks_path(:taks_type=>0))
  end

  def destroy
    @spider_cycle_task = SpiderCycleTask.find_by(id: params[:id])
    @spider_cycle_task.destroy

    render json: {type: "success",message:"删除成功！"} 
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
