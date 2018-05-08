class DispatcherHost  < DispatcherBase
  self.table_name = "hosts"


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
    installed_services = DispatcherHostService.group(:ip, :service_name)
    DispatcherHost.all.each do |host|
    end
  end

end
