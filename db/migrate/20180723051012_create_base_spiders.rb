class CreateBaseSpiders < ActiveRecord::Migration[5.1]
  def change
    create_table :base_spiders do |t|
      t.string :name
      t.string :template_name
      t.string :network_environment
      t.integer :control_template_id
      t.timestamps
    end
  end
end
