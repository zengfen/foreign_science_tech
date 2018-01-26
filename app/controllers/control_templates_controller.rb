class ControlTemplatesController < ApplicationController
  def index
    @templates = ControlTemplate.order('created_at desc').page(params[:page]).per(10)
  end

  def new
    @template = ControlTemplate.new
  end
end
