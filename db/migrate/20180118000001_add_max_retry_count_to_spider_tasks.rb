class AddMaxRetryCountToSpiderTasks < ActiveRecord::Migration[5.1]
  def change
  	add_column :spider_tasks, :max_retry_count, :integer, default: 2
  end
end
