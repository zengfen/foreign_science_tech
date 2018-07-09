# == Schema Information
#
# Table name: subtask_statuses
#
#  id            :string(32)       not null, primary key
#  task_id       :integer
#  status        :integer
#  created_at    :bigint(8)
#  error_content :text(65535)
#

class DispatcherSubtaskStatus < DispatcherBase
  self.table_name = "subtask_statuses"

  has_one :dispatcher_subtask, foreign_key: :id
  belongs_to :dispatcher_subtask, foreign_key: :id
end
