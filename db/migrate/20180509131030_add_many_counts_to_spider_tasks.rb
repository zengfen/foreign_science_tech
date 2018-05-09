class AddManyCountsToSpiderTasks < ActiveRecord::Migration[5.1]
  def change
    add_column :spider_tasks, :current_success_count, :int
    add_column :spider_tasks, :current_fail_count, :int
    add_column :spider_tasks, :current_warning_count, :int
    add_column :spider_tasks, :current_success_count, :int
    add_column :spider_tasks, :current_task_count, :int
  end
end
