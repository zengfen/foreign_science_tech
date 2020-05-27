class CreateSubtasks < ActiveRecord::Migration[5.0]
  def change
    create_table :subtasks, {id: :string, limit: 32}  do |t|
      t.integer :task_id
      t.integer :status, limit: 1, default: 0
      t.integer :cycle_status, limit: 1
      t.text :content
      t.text :error_content
      t.integer :error_at, limit: 8
      t.integer :competed_at, limit: 8
      t.integer :error_code
      t.index [:task_id]
      t.index [:task_id, :status], name: 'ts'
    end

  end
end
