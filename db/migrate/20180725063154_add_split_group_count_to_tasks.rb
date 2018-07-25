class AddSplitGroupCountToTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :spider_tasks, :split_group_count, :integer
    add_column :spider_cycle_tasks, :split_group_count, :integer
  end
end
