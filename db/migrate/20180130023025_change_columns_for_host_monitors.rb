class ChangeColumnsForHostMonitors < ActiveRecord::Migration[5.1]
  def change
  	remove_column :host_monitors, :cpu, :string
    remove_column :host_monitors, :memory, :string
    remove_column :host_monitors, :disk, :string

    add_column :host_monitors,:machine_info, :json
    add_column :host_monitors,:host_id, :integer
    add_index :host_monitors,:host_id, name: 'hm_hi'
  end
end