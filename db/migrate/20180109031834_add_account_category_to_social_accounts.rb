class AddAccountCategoryToSocialAccounts < ActiveRecord::Migration[5.1]
  def change
  	add_column :social_accounts, :account_category, :integer,:default=>0
  	add_index :social_accounts,:account_category, name: 'acinx'
  end
end
