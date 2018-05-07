class DispatcherAccount < ActiveRecord::Base
  establish_connection 'dispatcher'
  self.table_name = 'accounts'
end
