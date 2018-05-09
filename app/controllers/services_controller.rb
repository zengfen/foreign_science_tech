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
    start = (Time.now - 12.hours).at_beginning_of_hour.to_i

    @loaders = DispatcherHostService.where(service_name: 'receiver')

    @results = []
    @loaders.each do |loader|
      @results << [
        DispatcherHostTaskCounter
                  .where(ip: loader.ip)
                  .where("hour >= #{start}")
                  .order('hour desc'),
        DispatcherHostTaskCounter
        .select('sum(host_task_counters.receiver_batch_count) as receiver_batch_count, sum(host_task_counters.receiver_result_count) as receiver_result_count, sum(host_task_counters.receiver_bytes) as receiver_bytes,sum(host_task_counters.receiver_error_count) as receiver_error_count').where(ip: loader.ip).first
      ]
    end
  end
end
