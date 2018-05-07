class AddIsInternalToControlTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :control_templates, :is_internal, :boolean, default: true, null: false
  end
end
