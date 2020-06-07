class CreateAuthorCounter < ActiveRecord::Migration[5.0]
  def change
    create_table :author_counters do |t|
      t.string :author_name, :limit => 50
      t.integer :count, default: 0, null: false
      t.string  :current_date, :limit => 50
    end

    add_index :author_counters, :author_name
    add_index :author_counters, :current_date
  end
end
