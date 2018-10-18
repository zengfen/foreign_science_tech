class ServiceCodeVersionsController < ApplicationController
  before_action :logged_in_user

  def index
    ServiceCodeVersion.init_all

    @versions = ServiceCodeVersion.all
  end


  def package
    @version = ServiceCodeVersion.where(name: params[:name]).first
    @version.do_package_and_upload



    redirect_back(fallback_location: "/service_code_versions")
  end



end
