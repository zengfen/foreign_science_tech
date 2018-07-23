class CreateBaseSpiders < ActiveRecord::Migration[5.1]
  def change
    create_table :base_spiders do |t|

      t.timestamps
    end
  end
end
