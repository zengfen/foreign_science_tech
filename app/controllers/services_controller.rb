class ServicesController < ApplicationController
  def index
    ip = params[:keyword]
    service_names = params[:services]
    online_status = params[:online_status]
    @services, @running_services = DispatcherHost.service_details(ip, service_names, online_status)
  end

  def show
    ip = params[:ip]
    service_name = params[:service_name]

    @workers = DispatcherHostServiceWorker.where(ip: ip, service_name: service_name)
  end

  def receiver
    start = (Time.now - 12.hours).at_beginning_of_hour.to_i

    @receivers = DispatcherHostService.where(service_name: 'receiver')

    @results = []
    @receivers.each do |x|
      @results << [
        DispatcherHostTaskCounter
                  .where(ip: x.ip)
                  .where("hour >= #{start}")
                  .order('hour desc'),
        DispatcherHostTaskCounter
                  .select('sum(host_task_counters.receiver_batch_count) as receiver_batch_count, sum(host_task_counters.receiver_result_count) as receiver_result_count, sum(host_task_counters.receiver_bytes) as receiver_bytes,sum(host_task_counters.receiver_error_count) as receiver_error_count').where(ip: x.ip).first
      ]
    end
  end

  def loader
    start = (Time.now - 12.hours).at_beginning_of_hour.to_i

    @loaders = DispatcherHostService.where(service_name: 'loader')

    @results = []
    @loaders.each do |x|
      @results << [
        DispatcherHostTaskCounter
                  .where(ip: x.ip)
                  .where("hour >= #{start}")
                  .order('hour desc'),
        DispatcherHostTaskCounter
                  .select('sum(host_task_counters.loader_consume_count) as loader_consume_count, sum(host_task_counters.loader_load_count) as loader_load_count, sum(host_task_counters.loader_error_count) as loader_error_count').where(ip: x.ip).first
      ]
    end
  end

  def counters
    start = (Time.now - 12.hours).at_beginning_of_hour.to_i

    @loaders = DispatcherHostService.where(service_name: 'loader')

    fields = [
      "task_count",
      "discard_count",
      "completed_count",
      "result_count",
      "loader_consume_count",
      "loader_load_count",
      "dumper_task_count",
      "dumper_result_count",
      "receiver_batch_count",
      "receiver_result_count",
      "receiver_error_count",
      "receiver_bytes",
    ]

    select_query = fields.collect{|x| "sum(host_task_counters.#{x}) as #{x}"}.join(",")

    @results = [
      DispatcherHostTaskCounter
                .where("hour >= #{start}")
                .order('hour desc'),

      DispatcherHostTaskCounter
                .select(select_query).first
    ]
  end
end
