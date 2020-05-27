class SpidersController < ApplicationController
  # before_action :logged_in_user
  before_action :get_spider, only: %i[show show_info load_edit_form update destroy start stop]

  def index
    opts = {}
    opts[:spider_name] = params[:keyword] unless params[:keyword].blank?
    @spiders = Spider.where(opts).order('created_at desc').page(params[:page]).per(20)
    @spider = Spider.new
  end

  def show
    @spider = Spider.find(params[:id])
  end

  def create
    @spider = Spider.new(spider_params)
    if @spider.save
      flash[:success] = '创建成功'
    else
      flash[:error] = @spider.errors.full_messages.join('\n')
    end
    redirect_to spiders_path
  end

  def load_edit_form

  end

  def update
    if @spider.update(spider_params)
      flash[:success] = '更新成功！'
    else
      flash[:error] = spider.errors.full_messages.join('\n')
    end

    redirect_to spiders_path
  end

  def destroy
    render json: {type: 'success', message: '操作成功！'} if @spider.destroy
  end


  def start
    res = @spider.start_task(SpiderTask::RealTimeTask)
    if res[:type] == "success"
      flash[:success] = '更新成功！'
    else
      flash[:error] = res[:message]
    end
    redirect_to spiders_path
  end

  def stop
    @spider.stop_task(mode = SpiderTask::RealTimeTask)
  end


  private

  def spider_params
    params.require(:spider).permit(:spider_name)
  end

  def get_spider
    @spider = Spider.find_by(id: params[:id])
    redirect_to root_path if @spider.blank?
  end
end
