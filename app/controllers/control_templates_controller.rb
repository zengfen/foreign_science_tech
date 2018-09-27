class ControlTemplatesController < ApplicationController
  before_action :logged_in_user
  before_action :test_account,only: %i[create]
  def index
    @templates = ControlTemplate.order('created_at desc').page(params[:page]).per(10)
    @template = ControlTemplate.new
  end

  def new; end

  def create
    control_template_params = params
    .require(:control_template)
    .permit(:name, :is_bind_ip,
            :window_size, :window_type,
            :has_account, :start_delay,
            :is_internal,
            :is_reset,
            :end_delay, :max_count)

    @control_template = ControlTemplate.new(control_template_params)
    message = @control_template.save_with_calculate!

    flash[message.keys.first.to_sym] = message.values.first

    redirect_back(fallback_location: control_templates_path)
  end
end
