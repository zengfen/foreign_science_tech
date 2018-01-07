class CreateMediaAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :media_accounts do |t|
    	t.string :name
    	t.string :account_type 
    	t.string :account  
    	t.integer :status

      t.timestamps
    end
  end
end
