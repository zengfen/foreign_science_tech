class DispatcherRunningSubtask < ActiveRecord::Base
  establish_connection 'dispatcher'
  self.table_name = "running_subtasks"

end
