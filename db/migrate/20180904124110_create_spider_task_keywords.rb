class CreateSpiderTaskKeywords < ActiveRecord::Migration[5.1]
  def change
    create_table :spider_task_keywords do |t|

      t.timestamps
    end
  end
end
