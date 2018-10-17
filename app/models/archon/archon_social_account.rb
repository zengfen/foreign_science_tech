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
end
