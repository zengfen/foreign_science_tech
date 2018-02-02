class AddTimeLimitsToSpiderCycleTasks < ActiveRecord::Migration[5.1]
  def change
  	add_column :spider_cycle_tasks, :begin_time, :datetime
  	add_column :spider_cycle_tasks, :end_time, :datetime
  end
end
