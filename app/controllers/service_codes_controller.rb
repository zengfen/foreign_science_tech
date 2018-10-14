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
    base_params = params
    .require(:service_code)
    .permit(:name, :go_path,
            :code_path, :current_branch)


    @code.do_compile(base_params[:service_code][:go_path], base_params[:service_code][:code_path], base_params[:service_code][:current_branch])


    redirect_back(fallback_location: "/service_codes")
  end


end
