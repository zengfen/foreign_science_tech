class DispatcherSubtask < ActiveRecord::Base
  establish_connection 'dispatcher'
  self.table_name = "subtasks"

end
