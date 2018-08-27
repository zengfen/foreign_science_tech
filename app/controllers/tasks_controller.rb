class TasksController < ApplicationController
  before_action :logged_in_user
  before_action :get_spider_task ,:only=>[:fail_tasks,:retry_fail_task,:destroy_fail_task,:retry_all_fail_task]

  def index
    @spider_task = SpiderTask.new
    @spider_cycle_task = SpiderCycleTask.new

    opts = {}

    if !params[:keyword].blank?
      st_id_qs = SpecialTag.where(:id=>params[:keyword].to_i).collect{|x| x.id} 
      st_tag_qs = SpecialTag.where("tag like ?", "%#{params[:keyword]}%").collect{|x| x.id} 
      st_ids = st_id_qs + st_tag_qs
      opts[:special_tag] =  st_ids if !st_ids.blank?
    end

    if params[:task_type].blank?
      @spider_tasks = SpiderTask.includes("spider").where(opts).order("created_at desc").page(params[:page]).per(20)
      if request.xhr?
        return render "_list_body.html.erb", layout: false
      end
    else
      @spider_cycle_tasks = SpiderCycleTask.includes("spider").where(opts).order("created_at desc").page(params[:page]).per(20)
      if request.xhr?
        return render "_cycle_list_body.html.erb", layout: false
      end
    end
  end

  def gc
     GC.start
     memory = `ps -o rss= -p #{$$}`.to_i
     render plain: "hello, #{memory / 1024}MB\n #{GC.stat} \n"
  end

  def fail_tasks
    @fail_tasks =  DispatcherSubtaskStatus.where(task_id: @spider_task.id, status: 3).includes(:dispatcher_subtask).order("id asc").page(params[:page]).per(10)
  end


  def retry_fail_task
    @spider_task.retry_fail_task(params[:task_md5])

    flash[:success] = "操作成功！"
    redirect_back(fallback_location:fail_tasks_task_path(@spider_task))
  end


  def retry_all_fail_task
    @spider_task.retry_all_fail_task
    flash[:success] = "操作成功！"
    redirect_to tasks_path
  end


  def destroy_fail_task
    @spider_task.del_fail_task(params[:task_md5])

    render json: {type: "success",message:"删除成功！"}
    #redirect_back(fallback_location:fail_tasks_task_path(@spider_task))
  end

  def get_spider
    @spider = Spider.find_by(:id=>params[:id])

    if @spider.additional_function
      str = render_to_string(template: "/tasks/_additional_function.html.erb",:locals=>{:additional_function=>@spider.additional_function},:layout=>false)
    else
      str = ""
    end

    time_limits =  render_to_string(template: "/tasks/_time_limit.html.erb",:layout=>false)
    render json: {:type=>"#{@spider.has_keyword}",:instruction=>@spider.instruction.to_s,:add_funs=>str,:time_limits=>time_limits}
    #render plain: @spider.has_keyword
  end


  def results_trend
    key = "archon_task_total_results_#{params[:id]}"

    @results = $archon_redis.zrange(key, 0, -1, :withscores => true).sort_by{|x| x[0]}.to_h
  end

  private

  def get_spider_task
    @spider_task = SpiderTask.find_by(:id=>params[:id])
    redirect_back(fallback_location:root_path) if @spider_task.blank?
  end
end
