class CreateSocialAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :social_accounts do |t|
    	t.string :name
    	t.string :account_type 
    	t.string :account  
    	t.integer :status

      t.timestamps
    end
    add_index :social_accounts,:account_type, name: 'atinx'
    add_index :social_accounts,:account, name: 'account_inx'
    add_index :social_accounts,:name, name: 'nameinx'
  end
end
