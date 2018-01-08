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
        name = row["名称"].to_s.strip
        short_name = JSON.parse(row["简称"]).first
        ma = MediaAccount.find_by(:name=>name)
        ma = MediaAccount.new if ma.blank?
        ma.name = name
        ma.short_name = short_name
        ma.status = rand(0..1)
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


end
