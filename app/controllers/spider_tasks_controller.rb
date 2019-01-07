class SpiderTasksController < ApplicationController
  before_action :logged_in_user
  before_action :get_spider
  before_action :test_account,only: %i[create start stop destroy]

  def index
    opts = {}
    opts[:special_tag] = params[:keyword] unless params[:keyword].blank?
    @spider_tasks = @spider.spider_tasks.where(opts).order('created_at desc').page(params[:page]).per(10)
    @spider_task = SpiderTask.new
  end

  def new
    @spider_task = SpiderTask.new
  end

  def show; end

  def create
    @spider_task = SpiderTask.new(spider_task_params)
    @spider_task.special_tag_transfor_id
    add_funs = []
    params.keys.each do |key|
      if key.to_s =~ /cate_/
        if key.match("special_tags")
          add_funs << { key.gsub('cate_', '').to_s => SpiderTask.special_tag_transfor_id(params[key.to_sym])}
        else
          add_funs << { key.gsub('cate_', '').to_s => params[key.to_sym] }
        end
      end
    end

    @spider_task.begin_time = params[:begin_time] unless params[:begin_time].blank?
    @spider_task.end_time = params[:end_time] unless params[:end_time].blank?

    @spider_task.additional_function = add_funs
    message = @spider_task.save_with_spilt_keywords
    flash[message.keys.first.to_sym] = message.values.first

    redirect_back(fallback_location: tasks_path)
  end

  def start
    @spider_task = SpiderTask.find_by(id: params[:id])
    @spider_task.start!

    render template: '/tasks/refresh_spider_task.js.erb', layout: false
    # redirect_back(fallback_location:tasks_path)
  end

  def stop
    @spider_task = SpiderTask.find_by(id: params[:id])
    @spider_task.stop!

    render template: '/tasks/refresh_spider_task.js.erb', layout: false
    # redirect_back(fallback_location:tasks_path)
  end

  def destroy
    @spider_task = SpiderTask.find_by(id: params[:id])
    @spider_task.destroy

    render json: { type: 'success', message: '删除成功！' }
  end

  # 导出
  def output
    @spider_task = SpiderTask.find_by(id: params[:id])
    @spider_task.dump_crowed_file
    flash['success'] = '导出成功'

    redirect_back(fallback_location: tasks_path)
  end


  def output_csd
    @spider_task = SpiderTask.find_by(id: params[:id])
    @spider_task.dump_crowed_file(params[:name], params[:tag_ids])
    flash['success'] = '导出成功'

    redirect_back(fallback_location: tasks_path)
  end

  private

  def spider_task_params
    params.require(:spider_task).permit(:spider_id, :special_tag, :level, :keyword, :max_retry_count, :is_split, :begin_time, :end_time, :split_group_count, :timeout_second)
  end

  def get_spider
    @spider = Spider.find_by(id: params[:spider_id])
    redirect_to(root_url) if @spider.blank?
  end
end
