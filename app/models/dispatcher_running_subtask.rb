# == Schema Information
#
# Table name: running_subtasks
#
#  id         :string(255)      not null, primary key
#  task_id    :integer
#  ip         :string(255)
#  created_at :bigint(8)
#  account_id :integer
#

class DispatcherRunningSubtask < DispatcherBase
  self.table_name = "running_subtasks"

end
