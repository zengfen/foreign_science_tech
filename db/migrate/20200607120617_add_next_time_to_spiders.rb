class AddNextTimeToSpiders < ActiveRecord::Migration[5.0]
  def change
    add_column :spiders, :next_time, :datetime
  end
end
