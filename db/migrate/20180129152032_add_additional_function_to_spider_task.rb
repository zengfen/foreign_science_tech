class AddAdditionalFunctionToSpiders < ActiveRecord::Migration[5.1]
  def change
    add_column :spider_tasks, :additional_function, :json
    add_column :spider_cycle_tasks, :additional_function, :json
  end
end
