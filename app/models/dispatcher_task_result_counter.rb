# == Schema Information
#
# Table name: task_result_counters
#
#  task_id      :integer
#  ip           :string(255)
#  hour         :bigint(8)
#  result_count :integer
#

class DispatcherTaskResultCounter < DispatcherBase
  self.table_name = "task_result_counters"
end
