class ControlTemplatesController < ApplicationController
  def index
    @templates = ControlTemplate.order('created_at desc').page(params[:page]).per(10)
    @template = ControlTemplate.new
  end

  def new
  end


  def create
  end
end
