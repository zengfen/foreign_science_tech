class CreateServiceCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :service_codes do |t|
      t.string :name
      t.string :go_path
      t.string :code_path
      t.string :branchs
      t.string :current_branch
      t.timestamps
    end
  end
end
