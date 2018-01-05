class CreateHosts < ActiveRecord::Migration[5.1]
  def change
    create_table :hosts do |t|
    	t.inet :extranet_ip
    	t.inet :intranet_ip
    	t.integer :network_environment, default: 1
    	t.string :cpu
    	t.string :memory
    	t.string :disk
    	t.integer :host_status, default: 0
    	t.integer :process_status, default: 0
      t.timestamps
    end
  end
end