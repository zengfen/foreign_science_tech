class CreateSpiderTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :spider_tasks do |t|
      t.integer 'spider_id'
      t.integer 'level', default: 1
      t.text 'full_keywords', limit: 16777215
      t.integer 'status', default: 0
      t.integer 'task_type', default: 1
      t.integer 'current_task_count', default: 0, null: false
      t.integer 'current_success_count', default: 0, null: false
      t.integer 'current_fail_count', default: 0, null: false
      t.integer 'current_result_count', default: 0, null: false
      t.integer 'timeout_second', default: 15, null: false
      t.string 'special_tag_names'
      t.index ['spider_id'], name: 'spider_id'
      t.index ['task_type'], name: 'st_tt'

      t.timestamps
    end
  end
end
