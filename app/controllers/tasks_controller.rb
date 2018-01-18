class TasksController < ApplicationController

  def index
  	opts = {}
    opts[:special_tag] = params[:keyword] if !params[:keyword].blank?
		@spider_tasks = SpiderTask.includes("spider").where(opts).order("created_at desc").page(params[:page]).per(10)
  end

  def error_tasks
  	
  end

end
