# == Schema Information
#
# Table name: subtasks
#
#  id          :string(32)       not null, primary key
#  task_id     :integer
#  content     :text(65535)
#  retry_count :integer
#

class DispatcherSubtask < DispatcherBase
  self.table_name = "subtasks"


  has_one :dispatcher_subtask, foreign_key: :id
end
