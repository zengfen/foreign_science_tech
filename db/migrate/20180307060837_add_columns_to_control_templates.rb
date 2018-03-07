class AddColumnsToControlTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :control_templates, :has_account, :boolean, default: true, null: false
    add_column :control_templates, :start_delay, :float
    add_column :control_templates, :end_delay, :float
  end
end
