class DispatcherHost  < DispatcherBase
  self.table_name = "hosts"


  def self.service_names
    {
      'agent' => '爬虫节点',
      'supervisor' => '节点监控器',
      'controller' => '主机控制器',
      'dispatcher' => '任务分发器',
      'loader' => '数据loaders',
      'receiver' => '数据接收器',
      "dumper" => '数据导出器',
    }
  end

  def self.internal_agents
    ips = DispatcherHost.where(is_internal: true).collect(&:ip)
    DispatcherHostServiceWorker
      .where(service_name: "agent", ip: ips)
      .group(:ip, :service_name)
      .collect(&:ip)
  end

  def self.external_agents
    ips = DispatcherHost.where(is_internal: false).collect(&:ip)
    DispatcherHostServiceWorker
      .where(service_name: "agent", ip: ips)
      .group(:ip, :service_name)
      .collect(&:ip)
  end


  def self.list_services
    installed_services = {}

    DispatcherHostService.group(:ip, :service_name).each do |x|
      installed_services[x.ip] ||= []
      installed_services[x.ip] << service_names[x.service_name]
    end


    all_service_workers = DispatcherHostServiceWorker.order("last_active_at desc")

    running_services = {}

    running_service_counter = {}
    all_service_workers.each do |worker|
      running_services[worker.ip] ||= {}
      running_service_counter[worker.ip] ||= []

      next if running_services[worker.ip].key?(worker.service_name)


      running_services[worker.ip][worker.service_name] = Time.now.to_i - worker.last_active_at

      if (Time.now.to_i - worker.last_active_at) < 300
        running_service_counter[worker.ip] << service_names[worker.service_name]
      end
    end


    [DispatcherHost.all, installed_services, running_service_counter]
  end


  def network_environment_cn
    self.is_internal ? "境内" : "境外"
  end


  def self.service_details(ip, selected_services)
    hosts = {}

    DispatcherHost.all.each do |x|
      next if !ip.blank? && ip != x.ip
      hosts[x.ip] = x.is_internal
    end

    installed_services = {}

    DispatcherHostService.group(:ip, :service_name).each do |x|
      next if !ip.blank? && ip != x.ip
      next if !selected_services.blank? && !selected_services.include?(x.service_name)
      installed_services[x.ip] ||= []
      installed_services[x.ip] << [hosts[x.ip], x.service_name]
    end


    all_service_workers = DispatcherHostServiceWorker.order("last_active_at desc")

    running_services = {}

    running_service_counter = {}
    all_service_workers.each do |worker|

      next if !ip.blank? && ip != worker.ip
      next if !selected_services.blank? && !selected_services.include?(worker.service_name)

      running_services[worker.ip] ||= {}
      running_service_counter[worker.ip] ||= {}

      next if running_services[worker.ip].key?(worker.service_name)
      running_services[worker.ip][worker.service_name] = ""

      last_active_interval = (Time.now.to_i - worker.last_active_at)

      running_service_counter[worker.ip][worker.service_name] = [worker.last_active_at, last_active_interval < 300]
    end


    installed_services.each do |_ip, _services|
      running_service_counter[_ip] ||= {}
    end


    [installed_services, running_service_counter]

  end


end
