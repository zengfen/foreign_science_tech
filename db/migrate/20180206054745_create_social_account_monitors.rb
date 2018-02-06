class CreateSocialAccountMonitors < ActiveRecord::Migration[5.1]
  def change
    create_table :social_account_monitors do |t|
      t.string :account_type
      t.integer :spider_id
      t.string :cycle_type
      t.timestamps
    end
  end
end
