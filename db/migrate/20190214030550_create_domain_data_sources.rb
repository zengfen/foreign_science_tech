class CreateDomainDataSources < ActiveRecord::Migration[5.1]
  def change
    create_table :domain_data_sources do |t|
      t.string :domain, comment: '域名'
      t.text :rss_site, comment: 'RSS地址'
      t.string :newslookup, comment: 'newslookup id'

      t.timestamps
    end
  end
end
