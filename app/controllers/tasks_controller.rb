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

  def error_tasks
  	@task = SpiderTask.find(params[:id])
  	detail_data = $archon_redis.hgetall("archon_task_errors_#{@task.id}")

  	return render json: {type: "error",message:"失败任务数为空"} if detail_data.blank?
  	
  	total_detail_keys = detail_data.keys 
    @detail_keys =  Kaminari.paginate_array(total_detail_keys).page(params[:page]).per(10)
    @error_tasks = detail_keys.collect{|x| JSON.parse($archon_redis.hget("archon_task_details_#{@task.id}", x)) rescue {}}

  end

  def get_spider
  	@spider = Spider.find_by(:id=>params[:id])

    render plain: @spider.has_keyword
  end

end
