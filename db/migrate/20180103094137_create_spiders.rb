class CreateSpiders < ActiveRecord::Migration[5.1]
  def change
    create_table :spiders do |t|
    	t.string :spider_name
    	t.integer :spider_type
    	t.integer :network_environment, default: 1
    	t.boolean :proxy_support, default: false
    	t.boolean :has_keyword, default: false
    	t.string :template_name
    	t.string :category
    	t.json :additional_function, array: true

      t.timestamps
    end
  end
end