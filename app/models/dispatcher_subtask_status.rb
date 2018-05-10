class DispatcherSubtaskStatus < DispatcherBase
  self.table_name = "subtask_statuses"

  has_one :dispatcher_subtask_status, foreign_key: :id
  belongs_to :dispatcher_subtask_status, foreign_key: :id
end
