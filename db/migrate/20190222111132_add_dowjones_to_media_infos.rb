class AddDowjonesToMediaInfos < ActiveRecord::Migration[5.1]
  def change
    add_column :media_infos, :dowjones_source_code,:string
    add_column :media_infos, :en_intro,:text
    add_column :media_infos, :ch_intro,:text
  end
end