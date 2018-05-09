class ServicesController < ApplicationController

  def index
    ip, service_names = params[:keyword], params[:services]
    @services, @running_services = DispatcherHost.service_details(ip, service_names)
  end

  def show
  end

end
