class ServiceCodeVersionsController < ApplicationController
  before_action :logged_in_user

  def index
    ServiceCodeVersion.init_all

    @versions = ServiceCodeVersion.all
  end


  def package
    @code = ServiceCode.where(name: params[:name]).first
    base_params = params
    .require(:service_code)
    .permit(:name, :go_path,
            :code_path, :current_branch, :config_content)


    @code.do_compile(base_params[:go_path], base_params[:code_path], base_params[:current_branch], base_params[:config_content])


    redirect_back(fallback_location: "/service_codes")
  end



end
