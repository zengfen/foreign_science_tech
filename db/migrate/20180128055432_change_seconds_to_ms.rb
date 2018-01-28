class ChangeSecondsToMs < ActiveRecord::Migration[5.1]
  def change
    rename_column :control_templates, :interval_in_seconds, :interval_in_ms
    change_column :control_templates, :interval_in_ms, :integer
  end
end
