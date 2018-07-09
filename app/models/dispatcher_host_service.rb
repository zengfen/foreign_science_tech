# == Schema Information
#
# Table name: host_services
#
#  ip            :string(255)
#  service_name  :string(255)
#  error_content :string(255)
#  error_at      :bigint(8)
#

class DispatcherHostService  < DispatcherBase
  self.table_name = "host_services"
end
