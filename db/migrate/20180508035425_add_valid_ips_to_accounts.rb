class AddValidIpsToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :valid_ips, :array, default: [], null: false
  end
end
