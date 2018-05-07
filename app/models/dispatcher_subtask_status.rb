class DispatcherSubtaskStatus < ActiveRecord::Base
  establish_connection 'dispatcher'
  self.table_name = "subtask_statuses"
end
