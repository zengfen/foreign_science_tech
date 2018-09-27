class BaseSpidersController < ApplicationController
  before_action :logged_in_user
  before_action :get_spider, only: %i[show show_info load_edit_form update destroy]
  before_action :test_account,only: %i[create update destroy]
  def index
    @spiders = BaseSpider.order('created_at desc').page(params[:page]).per(20)
    @spider = BaseSpider.new

    @templates = ControlTemplate.select('id, name').collect { |x| [x.name, x.id] }.to_a
  end

  def show; end

  def create
    @spider = BaseSpider.new(spider_params)
    if @spider.save
      flash[:success] = '创建成功'
    else
      flash[:error] = @spider.errors.full_messages.join('\n')
    end
    redirect_to base_spiders_path
  end

  def load_edit_form
    @templates = ControlTemplate.select('id, name').collect { |x| [x.name, x.id] }.to_a
  end

  def update
    update_params = spider_params.clone

    if @spider.update_attributes(update_params)
      flash[:success] = '更新成功！'
    else
      flash[:error] = @spider.errors.full_messages.join('\n')
    end

    redirect_to spiders_path
  end

  def destroy
    render json: { type: 'success', message: '操作成功！' } if @spider.destroy
  end

  private

  def spider_params
    params.require(:base_spider).permit(:name, :template_name, :network_environment, :control_template_id)
  end

  def get_spider
    @spider = BaseSpider.find_by(id: params[:id])
    redirect_to root_path if @spider.blank?
  end


end
