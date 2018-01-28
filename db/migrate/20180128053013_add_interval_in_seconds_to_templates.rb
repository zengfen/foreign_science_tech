class AddIntervalInSecondsToTemplates < ActiveRecord::Migration[5.1]
  def change
    add_column :control_templates, :interval_in_seconds, :float
  end
end
