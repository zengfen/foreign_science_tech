# == Schema Information
#
# Table name: media_accounts
#
#  id         :integer          not null, primary key
#  name       :string
#  short_name :string
#  account    :string
#  status     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sc         :string
#  slg        :string
#  fmt        :string
#  sn         :string
#  asn        :string
#  dn         :string
#  std        :string
#  dsd        :string
#  lva        :string
#  lvs        :string
#  od         :string
#  fio        :string
#  de         :string
#  dea        :string
#  frp        :string
#  lag        :string
#  upn        :string
#  ntx        :string
#  pip        :string
#  url        :string
#  pbc        :string
#  pub        :string
#  lgo        :string
#  cir        :string
#  cis        :string
#  csn        :string
#  rst        :string
#  pst        :string
#  psd        :string
#  sfg        :string
#  roo        :string
#  mri        :string
#

class MediaAccount < ApplicationRecord

	def self.init_data(path)
	  type = path.split(".").last
    begin
      case type
      when "xlsx" then
        ss = Roo::Excelx.new(path)
      when "xls" then
        ss = Roo::Excel.new(path)
      when "csv" then
        ss = Roo::CSV.new(path)
      end
    rescue Exception=>e
      return false
    end
    ss.sheets.each do |s|
      ss.default_sheet = s
      header = ss.row(1).collect{|x| x.strip}
      for i in (ss.first_row+1)..ss.last_row
        row = Hash[[header, ss.row(i)].transpose]
        # name = row["名称"].to_s.strip
        # short_name = JSON.parse(row["简称"]).first
        name = row["news_publishername"].to_s.strip
        short_name = (name.include?" ")? name.split(' ').collect{|x| x.first}.join().upcase : name.upcase.to_s
        ma = MediaAccount.find_by(:name=>name)
        ma = MediaAccount.new if ma.blank?
        ma.name = name
        ma.short_name = short_name
        ma.status = 1
        ma.save
      end
    end 
	end


	def self.statuses
		{0=>"停止",1=>"采集中"}
	end

	def status_cn
		MediaAccount.statuses[self.status]
	end

  def self.check_files(root_path="/Users/li/Desktop/sourcelist")
    datas = []
    Find.find(root_path) do |path|  
      next unless %(xlsx xls csv).include?(path.split(".").last.downcase)
      puts path
      load_one_file(path) 
    end 
    return datas
  end

  def self.load_one_file(path)
    type = path.split(".").last.downcase
    begin
      case type
      when "xlsx" then
        ss = Roo::Excelx.new(path)
      when "xls" then
        ss = Roo::Excel.new(path)
      when "csv" then
        ss = Roo::CSV.new(path)
      end
    rescue Exception=>e
      return false
    end
   # ss.row(1).first.match(/rst=(.+?)\)/)[1]
      ss.sheets.each do |s|
      ss.default_sheet = s
      header = ss.row(2)
      for i in (ss.first_row+2)..ss.last_row
        row = Hash[[header, ss.row(i)].transpose]

      end
    end 
  end


end
