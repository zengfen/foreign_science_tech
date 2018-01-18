class AddWarningCountToSpiderTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :spider_tasks, :warning_count, :integer, default: 0
  end
end
