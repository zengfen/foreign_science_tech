class CreateSpiderCycleTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :spider_cycle_tasks do |t|
    	t.integer :spider_id
    	t.integer :level ,default:1
    	t.string :keyword
    	t.string :special_tag
    	t.integer :status ,default:0
    	t.integer :success_count ,default:0
    	t.integer :fail_count ,default:0
    	t.integer :max_retry_count,default:2
    	t.integer :warning_count,default:0
    	t.string  :period
    	t.datetime  :next_time

      t.timestamps
    end
    add_index :spider_cycle_tasks,:spider_id, name: 'sct_si'
  end
end
