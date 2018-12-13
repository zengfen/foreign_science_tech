class AddConfigContentToServiceCode1 < ActiveRecord::Migration[5.1]
  def change
    add_column :spider_tasks, :current_result_count, :integer, default: 0, null: false
  end
end
