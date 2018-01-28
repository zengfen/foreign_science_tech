class ControlTemplatesController < ApplicationController
  def index
    @templates = ControlTemplate.order('created_at desc').page(params[:page]).per(10)
    @template = ControlTemplate.new
  end

  def new; end

  def create
    control_template_params = params
                              .require(:control_template)
                              .permit(:name, :is_bind_ip, :window_size, :window_type, :max_count)

    @control_template = ControlTemplate.new(control_template_params)
    message = @control_template.save_with_calculate!

    flash[message.keys.first.to_sym] = message.values.first

    redirect_back(fallback_location: control_templates_path)
  end
end
