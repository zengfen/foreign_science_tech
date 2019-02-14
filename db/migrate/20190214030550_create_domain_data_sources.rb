class CreateDomainDataSources < ActiveRecord::Migration[5.1]
  def change
    create_table :domain_data_sources do |t|

      t.timestamps
    end
  end
end
