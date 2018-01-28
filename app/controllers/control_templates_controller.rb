class ControlTemplatesController < ApplicationController
  def index
    @templates = ControlTemplate.order('created_at desc').page(params[:page]).per(10)
    @template = ControlTemplate.new
  end

  def new
  end


  def create
    @control_template = ControlTemplate.new(params[:control_template])
    @control_template.save_with_calculate!
  end
end
