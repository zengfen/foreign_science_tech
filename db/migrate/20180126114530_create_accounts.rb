class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.string :content
      t.integer :account_type
      t.integer :control_template_id
      t.datetime :valid_time
      t.timestamps
    end
  end
end
