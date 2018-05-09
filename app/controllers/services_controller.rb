class ServicesController < ApplicationController

  def index
    @services, @running_services = DispatcherHost.service_details
  end

end
