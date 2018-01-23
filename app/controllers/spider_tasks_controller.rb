class SpiderTasksController < ApplicationController
  before_action :logged_in_user
	before_action :get_spider

  def index
		opts = {}
    opts[:special_tag] = params[:keyword] if !params[:keyword].blank?
		@spider_tasks = @spider.spider_tasks.where(opts).order("created_at desc").page(params[:page]).per(10)
		@spider_task = SpiderTask.new
  end

  def new
  	@spider_task = SpiderTask.new
  end

  def show

  end

  def create
  	@spider_task = SpiderTask.new(spider_task_params)
	  message = 	@spider_task.save_with_spilt_keywords
	  flash[message.keys.first.to_sym] = message.values.first

  	redirect_back(fallback_location:tasks_path)
  end


  def start
    @spider_task = SpiderTask.find_by(id: params[:id])
    @spider_task.start!

    redirect_back(fallback_location:tasks_path)
  end


  def stop
    @spider_task = SpiderTask.find_by(id: params[:id])
    @spider_task.stop!

    redirect_back(fallback_location:tasks_path)
  end


  private
  def spider_task_params
  		params.require(:spider_task).permit(:spider_id,:special_tag, :level, :keyword,:max_retry_count)
  end

  def get_spider
  	 @spider = Spider.find_by(id: params[:spider_id])
  	 redirect_to(root_url) if  @spider.blank?
  end
end
