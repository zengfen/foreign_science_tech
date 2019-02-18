class AddStatusToGovernmentInfos < ActiveRecord::Migration[5.1]
  def change
    add_column :government_infos, :status,:string
  end
end