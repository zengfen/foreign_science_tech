# == Schema Information
#
# Table name: host_task_counters
#
#  ip                    :string(255)
#  hour                  :bigint(8)
#  task_count            :integer          default(0)
#  discard_count         :integer          default(0)
#  completed_count       :integer          default(0)
#  result_count          :integer          default(0)
#  left_result_count     :integer          default(0)
#  receiver_result_count :integer          default(0)
#  loader_consume_count  :integer          default(0)
#  loader_load_count     :integer          default(0)
#  dumper_task_count     :integer          default(0)
#  dumper_result_count   :integer          default(0)
#  receiver_error_count  :integer          default(0)
#  loader_error_count    :integer          default(0)
#  receiver_bytes        :integer          default(0)
#  receiver_batch_count  :integer          default(0)
#

class DispatcherHostTaskCounter < DispatcherBase
  self.table_name = "host_task_counters"

end
