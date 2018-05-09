class ServicesController < ApplicationController
  def index
    ip = params[:keyword]
    service_names = params[:services]
    @services, @running_services = DispatcherHost.service_details(ip, service_names)
  end

  def show
    ip = params[:ip]
    service_name = params[:service_name]

    @workers = DispatcherHostServiceWorker.where(ip: ip, service_name: service_name)
  end

  def receiver
    start = (Time.now - 12.hours).at_beginning_of_hour

    @loaders = DispatcherHostService.where(service_name: 'receiver')

    @results = []
    loaders.each do |loader|
      @results << DispatcherHostTaskCounter
        .where(ip: loader.ip)
                  .where("hour > #{start}")
                  .order('hour desc')

      @results << DispatcherHostTaskCounter
        .where(ip: loader.ip)
                  .sum(:receiver_batch_count, :receiver_result_count,
                       :receiver_bytes, :receiver_error_count)
    end
  end
end
