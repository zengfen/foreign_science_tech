class ServiceCodesController < ApplicationController
  before_action :logged_in_user

  def index
    ServiceCode.init_all

    @codes = ServiceCode.all
  end


  def compile
    @code = ServiceCode.where(name: params[:name]).first
  end


  def do_compile
    @code = ServiceCode.where(name: params[:name]).first
  end


end
