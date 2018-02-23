class AddFieldsToSocialAccountMonitor < ActiveRecord::Migration[5.1]
  def change
    add_column :social_account_monitors, :max_retry_count, :integer, default: 1
    add_column :social_account_monitors, :level, :integer, default: 1
    add_column :social_account_monitors, :special_tag, :string
  end
end
