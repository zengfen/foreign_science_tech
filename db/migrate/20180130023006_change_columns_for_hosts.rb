class ChangeColumnsForHosts < ActiveRecord::Migration[5.1]
  def change
    remove_column :hosts, :cpu, :string
    remove_column :hosts, :memory, :string
    remove_column :hosts, :disk, :string
    add_column :hosts,:host_service_info, :json
    add_column :hosts,:host_service, :string , array: true
    add_column :hosts,:machine_info, :json
    add_column :hosts,:recording_time,:datetime
    add_index :hosts,:host_service, name: 'h_hs'
  end
end