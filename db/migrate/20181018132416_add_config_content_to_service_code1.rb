class AddConfigContentToServiceCode1 < ActiveRecord::Migration[5.1]
  def change
    add_column :service_codes, :config_content, :text
  end
end
