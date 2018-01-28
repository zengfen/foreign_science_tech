class ControlTemplatesController < ApplicationController
  def index
    @templates = ControlTemplate.order('created_at desc').page(params[:page]).per(10)
    @template = ControlTemplate.new
  end

  def new
  end


  def create
    @control_template = ControlTemplate.new(params[:control_template])
    message = @control_template.save_with_calculate!

	  flash[message.keys.first.to_sym] = message.values.first

  	redirect_back(fallback_location: control_templates_path)
  end
end
