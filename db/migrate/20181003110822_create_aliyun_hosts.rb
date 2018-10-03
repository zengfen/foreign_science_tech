class CreateAliyunHosts < ActiveRecord::Migration[5.1]
  def change
    create_table :aliyun_hosts do |t|
      t.string :instance_id
      t.string :public_ip
      t.timestamps
    end
  end
end
