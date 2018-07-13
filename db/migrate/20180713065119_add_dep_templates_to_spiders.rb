class AddDepTemplatesToSpiders < ActiveRecord::Migration[5.1]
  def change
    add_column :spiders, :dep_templates, :json, null: false, default: {}
  end
end
