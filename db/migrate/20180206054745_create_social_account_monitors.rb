class CreateSocialAccountMonitors < ActiveRecord::Migration[5.1]
  def change
    create_table :social_account_monitors do |t|

      t.timestamps
    end
  end
end
