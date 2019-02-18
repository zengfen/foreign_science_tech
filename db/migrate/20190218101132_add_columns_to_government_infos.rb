class AddColumnsToGovernmentInfos < ActiveRecord::Migration[5.1]
  def change
    add_column :government_infos, :org_name, :string
    add_column :government_infos, :twitter_screen_name,:string
    add_column :government_infos, :facebook_screen_name,:string
    add_column :government_infos, :youtube_screen_name,:string
    add_column :government_infos, :instagram_screen_name,:string
  end
end