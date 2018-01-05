class CreateSpiderTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :spider_tasks do |t|
    	t.integer :spider_id
    	t.integer :level ,default:1
    	t.string :keyword
    	t.string :special_tag
    	t.integer :status ,default:0
    	t.integer :success_count ,default:0
    	t.integer :fail_count ,default:0
    	t.datetime :refresh_time
      t.timestamps
    end
    add_index :spider_tasks,:spider_id, name: 'spider_id'
  end
end
