class ArchonSocialAccount  < ArchonBase
  def self.load
    records = []
    File.new("db/social_account.txt").each do |line|
      next if line.blank?
      record = self.new(JSON.parse(line))

      if !record.account.blank?
        next if record.account.size >= 255
      end

      records << record
      if records.size == 1000
        self.import records

        records = []
      end
    end

    if records.size > 0
      self.import records
    end

    nil
  end


  def self.statuses
    {0=>"停止",1=>"采集中"}
  end

  def status_cn
    self.statuses[self.status]
  end

  def self.account_categories
    {0=>"组织",1=>"人物"}
  end

  def account_category_cn
    self.account_categories[self.account_category]
  end


end
