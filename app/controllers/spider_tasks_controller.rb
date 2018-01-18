class SpiderTasksController < ApplicationController
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

  	redirect_to spider_spider_tasks_path(@spider)
  end


  def start
  end


  def stop
  end


  private
  def spider_task_params
  		params.require(:spider_task).permit(:spider_id,:special_tag, :level, :keyword)
  end

  def get_spider
  	 @spider = Spider.find_by(id: params[:spider_id])
  	 redirect_to(root_url) if  @spider.blank?
  end
end
