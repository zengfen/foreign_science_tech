class AddIsResetToControlTemplate < ActiveRecord::Migration[5.1]
  def change
    add_column :control_templates, :is_reset, :boolean, default: false, null: false
  end
end
