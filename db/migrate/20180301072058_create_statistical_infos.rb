class CreateStatisticalInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :statistical_infos do |t|
    	t.string :host_ip
      t.integer :info_type
      t.integer :count
      t.datetime :recording_time
      t.string :hour_field

      t.timestamps
    end
     add_index :statistical_infos,[:host_ip,:info_type,:recording_time,:hour_field], name: 'si_hirh'
  end
end
