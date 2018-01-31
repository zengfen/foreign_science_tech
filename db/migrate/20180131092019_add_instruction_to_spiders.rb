class AddInstructionToSpiders < ActiveRecord::Migration[5.1]
  def change
  	 add_column :spiders, :instruction, :string
  end
end
