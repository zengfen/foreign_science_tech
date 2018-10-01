class ChangeMaxRetryCountDefault < ActiveRecord::Migration[5.1]
  def change
    change_column :spider_tasks, :max_retry_count, null: false, default: 0
    change_column :spider_cycle_tasks, :max_retry_count, null: false, default: 0
  end
end
