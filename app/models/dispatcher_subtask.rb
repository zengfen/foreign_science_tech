class DispatcherSubtask < DispatcherBase
  self.table_name = "subtasks"


  has_one :dispatcher_subtask, foreign_key: :id
end
