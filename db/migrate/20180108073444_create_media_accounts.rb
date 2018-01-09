class CreateMediaAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :media_accounts do |t|
    	t.string :name
    	t.string :short_name 
    	t.string :account  
    	t.integer :status      
    	t.timestamps
    end
    add_index :media_accounts,:name, name: 'name_index'
    add_index :media_accounts,:short_name, name: 'short_name_index'
  end
end

