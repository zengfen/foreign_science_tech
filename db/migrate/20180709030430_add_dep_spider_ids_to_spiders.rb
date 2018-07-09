class AddDepSpiderIdsToSpiders < ActiveRecord::Migration[5.1]
  def change
    add_column :spiders, :dep_control_template_ids, :integer, array: true, null: false, default: []
  end
end
