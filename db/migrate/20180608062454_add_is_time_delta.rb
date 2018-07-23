class AddIsTimeDelta < ActiveRecord::Migration[5.1]
  def change
    add_column :spider_cycle_tasks, :is_time_detla, :boolean, default: false, null: false
  end
end
