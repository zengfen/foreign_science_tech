# == Schema Information
#
# Table name: host_service_workers
#
#  ip             :string(255)
#  service_name   :string(255)
#  worker_name    :string(255)
#  last_active_at :bigint(8)
#

class DispatcherHostServiceWorker  < DispatcherBase
  self.table_name = "host_service_workers"
end
