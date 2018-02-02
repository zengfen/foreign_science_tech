class AddTimeLimitToSpiders < ActiveRecord::Migration[5.1]
  def change
  	add_column :spiders, :has_time_limit, :boolean, default: false
  end
end