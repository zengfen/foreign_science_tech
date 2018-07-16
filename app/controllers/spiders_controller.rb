class SpidersController < ApplicationController
  before_action :logged_in_user
  before_action :get_spider, only: %i[show show_info load_edit_form update destroy]

  def index
    opts = {}
    opts[:category] = params[:category] unless params[:category].blank?
    opts[:spider_name] = params[:keyword] unless params[:keyword].blank?
    @spiders = Spider.where(opts).order('created_at desc').page(params[:page]).per(20)
    @spider = Spider.new

    @templates = ControlTemplate.select('id, name').collect { |x| [x.name, x.id] }.to_a
  end

  def show; end

  def create
    @spider = Spider.build_spider(spider_params)
    if @spider.save
      flash[:success] = '创建成功'
    else
      flash[:error] = @spider.errors.full_messages.join('\n')
    end
    redirect_to spiders_path
  end

  def load_edit_form
    @templates = ControlTemplate.select('id, name').collect { |x| [x.name, x.id] }.to_a
  end

  def update
    update_params = spider_params.clone
    additional_function = update_params.delete(:additional_function)

    if !additional_function.blank?
      begin
        update_params[:additional_function] = JSON.parse(additional_function)
      rescue StandardError
        @spider.errors.add(:additional_function, '格式错误')
        flash[:error] = @spider.errors.full_messages.join('\n')
        redirect_to spiders_path
        return
      end
    else
      update_params[:additional_function] = []
    end

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
    params.require(:spider).permit(:spider_name, :spider_type, :network_environment, :proxy_support, :has_keyword, :template_name, :category, :additional_function, :control_template_id,:instruction,:has_time_limit, :template_name1, :template_name2, :template_name3, :template_name4,:template_name5, :control_template_id1, :control_template_id2, :control_template_id3, :control_template_id4, :control_template_id5)
  end

  def get_spider
    @spider = Spider.find_by(id: params[:id])
    redirect_to root_path if @spider.blank?
  end
end
