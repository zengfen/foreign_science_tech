class AddIsSplitToSpiderCycleTasks < ActiveRecord::Migration[5.1]
  def change
  	add_column :spider_cycle_tasks, :is_split, :boolean, default: false
    change_column :spider_cycle_tasks, :keyword, :text
  end
end
