class CreateSpiderCycleTaskKeywords < ActiveRecord::Migration[5.1]
  def change
    create_table :spider_cycle_task_keywords do |t|
      t.integer :spider_task_id
      t.text :keyword
    end
  end
end
