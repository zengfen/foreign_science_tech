class AddIsRunningToHosts < ActiveRecord::Migration[5.1]
  def change
    add_column :aliyun_hosts, :is_running, :boolean, default: false, null: false
  end
end
