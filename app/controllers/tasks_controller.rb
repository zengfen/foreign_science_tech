class TasksController < ApplicationController
  before_action :logged_in_user
  before_action :get_spider_task ,:only=>[:fail_tasks,:retry_fail_task,:destroy_fail_task,:retry_all_fail_task]

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
    total_detail_keys = $archon_redis.smembers("archon_discard_tasks_#{@spider_task.id}")

    if total_detail_keys.blank?
      flash[:error] = "失败任务数为空"
      redirect_to tasks_path
      return
    end

    @detail_keys =  Kaminari.paginate_array(total_detail_keys).page(params[:page]).per(10)
    @fail_tasks = @detail_keys.collect{|x| JSON.parse($archon_redis.hget("archon_task_details_#{@spider_task.id}", x)) rescue {}}
    task_error = $archon_redis.hmget("archon_task_errors_#{@spider_task.id}", *@detail_keys)
    @fail_task_errors = @detail_keys.each_with_index.collect{|x, i| [x, task_error[i]]}.to_h
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
