class CreateControlTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :control_templates do |t|
      t.string :name
      t.boolean :is_bind_ip
      t.integer :window_type
      t.integer :window_size
      t.integer :max_count
      t.boolean :is_absolute_time
      t.timestamps
    end
  end
end
