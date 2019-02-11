class CreateGovernmentInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :government_infos do |t|
      t.integer :level, comment: '级别'
      t.string :ch_name, comment: '媒体中文名'
      t.string :en_name, comment: '媒体英文名'
      t.integer :country_code, comment: '国家代码'
      t.string :site, comment: '网址（URL）'
      t.string :domain, comment: '域名'
      t.string :data_source, comment: '数据来源'
      t.string :remark, comment: '备注'
      t.string :rss_site, comment: 'RSS地址'
      t.string :ch_name, comment: '媒体中文名'
      t.string :category, comment: '类别'
      t.timestamps
    end
  end
end
