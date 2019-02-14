class ChangeSecondsToMs < ActiveRecord::Migration[5.1]
  def change
    change_column :government_infos, :level, :string
    change_column :media_infos, :level, :string
  end
end
