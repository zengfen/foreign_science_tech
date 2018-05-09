class ServicesController < ApplicationController

  def index
    ip, service_names = params[:keyword], params[:services]
    @services, @running_services = DispatcherHost.service_details(ip, service_names)
  end

  def show
    ip = params[:ip]
    service_name = params[:service_name]

    @workers = DispatcherHostServiceWorker.where(:ip => ip, :service_name => service_name)
  end

end
