class TasksController < ApplicationController
  before_action :logged_in_user

  def index
  	@spider_task = SpiderTask.new
		@spider_cycle_task = SpiderCycleTask.new

  	opts = {}
    opts[:special_tag] = params[:keyword] if !params[:keyword].blank?

		if params[:task_type].blank?
			@spider_tasks = SpiderTask.includes("spider").where(opts).order("created_at desc").page(params[:page]).per(10)
			if request.xhr? 
				return render "_list_body.html.erb", layout: false 
			end
		else
			@spider_cycle_tasks = SpiderCycleTask.includes("spider").where(opts).order("created_at desc").page(params[:page]).per(10)
      if request.xhr?  
	    	return render "_cycle_list_body.html.erb", layout: false 
	    end
    end
  end

  def fail_tasks
  	@spider_task = SpiderTask.find_by(:id=>params[:id])
  	total_detail_keys = $archon_redis.smembers("archon_discard_tasks_#{@spider_task.id}")
 
  	if total_detail_keys.blank?
  		flash[:error] = "失败任务数为空"
  		redirect_back(fallback_location:tasks_path)
  		return 
  	end
 
    @detail_keys =  Kaminari.paginate_array(total_detail_keys).page(params[:page]).per(10)
    @fail_tasks = @detail_keys.collect{|x| JSON.parse($archon_redis.hget("archon_task_details_#{@spider_task.id}", x)) rescue {}}

  end


  def retry_fail_task
  	@spider_task = SpiderTask.find_by(:id=>params[:id])
  	@spider_task.retry_fail_task(params[:task_md5])

  	flash[:success] = "操作成功！"
    redirect_back(fallback_location:error_tasks_task_path(@spider_task))  
  end


  def destroy_fail_task
  	@spider_task = SpiderTask.find_by(:id=>params[:id])
  	@spider_task.del_fail_task(params[:task_md5])
   
    render json: {type: "success",message:"删除成功！"} 
    #redirect_back(fallback_location:error_tasks_task_path(@spider_task))
  end

  def get_spider
  	@spider = Spider.find_by(:id=>params[:id])

    render plain: @spider.has_keyword
  end

end
