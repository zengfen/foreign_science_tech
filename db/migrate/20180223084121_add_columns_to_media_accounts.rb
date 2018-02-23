class AddColumnsToMediaAccounts < ActiveRecord::Migration[5.1]
  def change
  	add_column :media_accounts, :sc, :string
  	add_column :media_accounts, :slg, :string
  	add_column :media_accounts, :fmt, :string
  	add_column :media_accounts, :sn, :string
  	add_column :media_accounts, :asn, :string
  	add_column :media_accounts, :dn, :string
  	add_column :media_accounts, :std, :string
  	add_column :media_accounts, :dsd, :string
  	add_column :media_accounts, :lva, :string
  	add_column :media_accounts, :lvs, :string
  	add_column :media_accounts, :od, :string
  	add_column :media_accounts, :fio, :string
  	add_column :media_accounts, :de, :string
  	add_column :media_accounts, :dea, :string
  	add_column :media_accounts, :frp, :string
  	add_column :media_accounts, :lag, :string
  	add_column :media_accounts, :upn, :string
  	add_column :media_accounts, :ntx, :string
  	add_column :media_accounts, :pip, :string
  	add_column :media_accounts, :url, :string
  	add_column :media_accounts, :pbc, :string
  	add_column :media_accounts, :pub, :string
  	add_column :media_accounts, :lgo, :string
  	add_column :media_accounts, :cir, :string
    add_column :media_accounts, :cis, :string
    add_column :media_accounts, :csn, :string
    add_column :media_accounts, :rst, :string
    add_column :media_accounts, :pst, :string
    add_column :media_accounts, :psd, :string
    add_column :media_accounts, :sfg, :string
    add_column :media_accounts, :roo, :string
    add_column :media_accounts, :mri, :string

    add_index :media_accounts,:sc, name: 'ma_sc'
  end
end
