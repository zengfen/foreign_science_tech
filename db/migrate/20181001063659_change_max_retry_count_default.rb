class ChangeMaxRetryCountDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :spider_tasks, :max_retry_count, from: 2, to: 0
    change_column_default :spider_cycle_tasks, :max_retry_count, from: 2, to: 0
  end
end
