class RenameIsTimeDetla < ActiveRecord::Migration[5.1]
  def change
    rename_column :spider_cycle_tasks, :is_time_detla, :is_time_delta
  end
end
