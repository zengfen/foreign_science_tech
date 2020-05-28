class SpiderTasksController < ApplicationController
  # before_action :logged_in_user
  before_action :get_spider_task, only: %i[retry_fail_task destroy_fail_task retry_all_fail_task]

  def index
    @spider_task = SpiderTask.new
    opts = {}
    unless params[:id].blank?
      opts[:id] = params[:id].split(',')
    end
    opts[:spider_id] = params[:spider_id] unless params[:spider_id].blank?
    opts[:status] = params[:status] unless params[:status].blank?
    opts[:task_type] = params[:task_type] unless params[:task_type].blank?

    @spider_tasks = SpiderTask.includes('spider').where(opts).order(id: :desc).page(params[:page]).per(20)
  end


  def fail_tasks
    spider_task = Spider.where(id:params[:id]).first.spider_tasks.order(:created_at).last.id rescue nil
    @fail_tasks = Subtask.where(task_id: spider_task, status: Subtask::TypeSubtaskError).page(params[:page]).per(20)
  end

  def show_keyword
    render plain: SpiderTask.where(id: params[:id]).first.full_keywords
  end


  private

  def get_spider_task
    @spider_task = SpiderTask.find_by(id: params[:id])
    redirect_back(fallback_location: root_path) if @spider_task.blank?
  end
end
