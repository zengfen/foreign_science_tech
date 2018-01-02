class AddColumnsToUsers < ActiveRecord::Migration[5.1]
  def change
  	add_column :users, :avatar, :string
  	add_column :users, :reset_digest, :string
  	add_column :users, :reset_sent_at, :string
  end
end
