class CreateSpecialTags < ActiveRecord::Migration[5.1]
  def change
    create_table :special_tags do |t|
      t.string :tag
      t.timestamps
    end
    add_index :special_tags,[:tag], name: 'spe_tag'
  end
end
