class CreateServiceCodeVersions < ActiveRecord::Migration[5.1]
  def change
    create_table :service_code_versions do |t|
      t.string :name
      t.string :file_path
      t.string :sha1_code
      t.timestamps
    end
  end
end
