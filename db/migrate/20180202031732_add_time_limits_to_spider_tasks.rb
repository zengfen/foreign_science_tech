class AddTimeLimitsToSpiderTasks < ActiveRecord::Migration[5.1]
  def change
  	add_column :spider_tasks, :begin_time, :datetime
  	add_column :spider_tasks, :end_time, :datetime
  end
end
