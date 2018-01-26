class CreateControlTemplates < ActiveRecord::Migration[5.1]
  def change
    create_table :control_templates do |t|
      t.string :account

      t.timestamps
    end
  end
end
