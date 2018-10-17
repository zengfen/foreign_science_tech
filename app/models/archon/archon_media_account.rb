class ArchonMediaAccount  < ArchonBase
  def self.load
    records = []
    File.new("db/media_account.txt").each do |line|
      next if line.blank?
      records << self.new(JSON.parse(line))
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
