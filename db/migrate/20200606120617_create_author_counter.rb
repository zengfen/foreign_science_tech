class CreateAuthorCounter < ActiveRecord::Migration[5.0]
  def change
    create_table :author_counters do |t|
      t.string :con_author, :limit => 50
      t.integer :count, default: 0, null: false
      t.date  :con_date
    end

    add_index :author_counters, :con_author
    add_index :author_counters, :con_date
  end
end
