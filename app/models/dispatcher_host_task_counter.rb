class DispatcherHostTaskCounter < ActiveRecord::Base
  establish_connection 'dispatcher'
  self.table_name = "host_task_counters"

end
