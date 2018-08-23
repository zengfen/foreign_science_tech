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


  def self.list_recent_24hours_trend()
    # start_time = Time.now.
  end
end
