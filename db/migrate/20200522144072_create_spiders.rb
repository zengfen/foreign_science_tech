class CreateSpiders < ActiveRecord::Migration[5.0]
  def change
    create_table :spiders do |t|
      t.string 'spider_name'
      t.string 'name_cn'
      t.string 'name_en'
      t.integer 'status',default:0
      t.integer 'real_time_status',default:0
      t.timestamps
    end

    add_index :spiders, :spider_name, unique: true
  end
end
