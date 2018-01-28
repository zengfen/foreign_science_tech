class AddControlTemplateIdToSpiders < ActiveRecord::Migration[5.1]
  def change
    add_column :spiders, :control_template_id, :integer
  end
end
