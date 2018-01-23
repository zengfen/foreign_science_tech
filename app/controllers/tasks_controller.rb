class TasksController < ApplicationController
  before_action :logged_in_user

  def index
  	opts = {}
    opts[:special_tag] = params[:keyword] if !params[:keyword].blank?
		@spider_tasks = SpiderTask.includes("spider").where(opts).order("created_at desc").page(params[:page]).per(10)
		@spider_task = SpiderTask.new
		@spider_cycle_task = SpiderCycleTask.new
  end

  def error_tasks
  	@task = SpiderTask.find(params[:id])
  	@error_details = $archon_redis.hget("archon_tasks_errors_#{@task.id}")
  end

  def new_spider_task
  	@spider_task = SpiderTask.new
  end

  def new_spider_cycle_task
  	@spider_cycle_task = SpiderCycleTask.new
  end

  def get_spider
  	@spider = Spider.find_by(:id=>params[:id])

    render plain: @spider.has_keyword
  end

end
