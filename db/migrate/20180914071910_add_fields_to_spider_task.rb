class AddFieldsToSpiderTask < ActiveRecord::Migration[5.1]
  def change
    add_column :spider_tasks, :timeout_second, :integer, default: 15, null: false
    add_column :spider_cycle_tasks, :timeout_second, :integer, default: 15, null: false
  end
end
