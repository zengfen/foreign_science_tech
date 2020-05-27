class CommonBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection CommonDataDB

# CommonBase.create_table
  def self.create_table
    files = ["t_data.sql", "t_log_spider.sql", "t_sk_job_instance.sql"]
    files.each do |file|
      `bundle exec rails db < "#{Rails.root}/public/sql/#{file}"`
    end
  end
end
