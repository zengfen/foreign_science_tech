class AddSpiderCycleTaskIdToSpiderTask < ActiveRecord::Migration[5.1]
  def change
  	 add_column :spider_tasks, :spider_cycle_task_id, :integer
  	 add_column :spider_tasks, :task_type, :integer,default: 1
  	 add_index :spider_tasks,:spider_cycle_task_id, name: 'st_scti'
     add_index :spider_tasks,:task_type, name: 'st_tt'
  end
end