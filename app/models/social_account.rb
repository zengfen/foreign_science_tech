# == Schema Information
#
# Table name: social_accounts
#
#  id               :integer          not null, primary key
#  name             :string
#  account_type     :string
#  account          :string
#  status           :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  account_category :integer          default("0")
#

class SocialAccount < ApplicationRecord

  def self.import_data
    max_count = File.open("#{Rails.root}/tmp/people.csv").readlines.count
    File.open("#{Rails.root}/tmp/people.csv").readlines.each_with_index do |line,i|
      next if i < 224774
      doc = line.split("\",\"").collect{|x| x.gsub("\"","")}
      puts "-"*100 + "index:#{i},max:#{max_count}"
      if !doc[6].blank?
        ma = SocialAccount.find_by(account: doc[6])
        ma = SocialAccount.new if ma.blank?
        ma.name = "#{doc[2]} #{doc[3]}"
        ma.account_type = "facebook"
        ma.account = doc[6]
        ma.account_category = 1
        ma.status = rand(0..1)
        ma.save
      end
      if !doc[7].blank?
        ma = SocialAccount.find_by(account: doc[7])
        ma = SocialAccount.new if ma.blank?
        ma.name = "#{doc[2]} #{doc[3]}"
        ma.account_type = "twitter"
        ma.account = doc[7]
        ma.account_category = 1
        ma.status = rand(0..1)
        ma.save
      end
      if !doc[8].blank?
        ma = SocialAccount.find_by(account: doc[8])
        ma = SocialAccount.new if ma.blank?
        ma.name = "#{doc[2]} #{doc[3]}"
        ma.account_type = "linkedin"
        ma.account = doc[8]
        ma.account_category = 1
        ma.status = rand(0..1)
        ma.save
      end
    end
  end

  def self.init_data(path)
    file = File.read(path)
    json_value = JSON.parse(file)
    json_value.each do |k,v|
      next if (!v.has_key?"fb")&&(!v.has_key?"tw")&&(!v.has_key?"ytb")&&(!v.has_key?"lk")
      if !v["fb"].blank? && v["fb"]!="未发现"
        ma = SocialAccount.find_by(account: v["fb"])
        ma = SocialAccount.new if ma.blank?
        ma.name = k
        ma.account_type = "facebook"
        ma.account = v["fb"]
        ma.status = rand(0..1)
        ma.save
      end
      if !v["tw"].blank? && v["tw"]!="未发现"
        ma = SocialAccount.find_by(account: v["tw"])
        ma = SocialAccount.new if ma.blank?
        ma.name = k
        ma.account_type = "twitter"
        ma.account = v["tw"]
        ma.status = rand(0..1)
        ma.save
      end
      if !v["ytb"].blank? && v["ytb"]!="未发现"
        ma = SocialAccount.find_by(account: v["ytb"])
        ma = SocialAccount.new if ma.blank?
        ma.name = k
        ma.account_type = "youtube"
        ma.account = v["ytb"]
        ma.status = rand(0..1)
        ma.save
      end
      if !v["lk"].blank? && v["lk"]!="未发现"
        ma = SocialAccount.find_by(account: v["lk"])
        ma = SocialAccount.new if ma.blank?
        ma.name = k
        ma.account_type = "linkedin"
        ma.account = v["lk"]
        ma.status = rand(0..1)
        ma.save
      end
    end
  end

 	def self.import_people_datas(path="#{Rails.root}/people.csv")
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
        next if (!row.has_key?"twitter_url")&&(!row.has_key?"facebook_url")&&(!row.has_key?"linkedin_url")
        name = "#{row["first_name"].to_s.strip} #{row["last_name"].to_s.strip}"
        puts i
        # break if i==100
	      if !row["twitter_url"].blank?
	        ma = SocialAccount.find_by(:account=>row["twitter_url"])
	        ma = SocialAccount.new if ma.blank?
	        ma.name = name
	        ma.account_type = "twitter"
	        #个人
	        ma.account_category = 1
	        ma.account = row["twitter_url"]
	        ma.status = 1
	        ma.save
	      end
	      if !row["facebook_url"].blank?
	        ma = SocialAccount.find_by(:account=>row["facebook_url"])
	        ma = SocialAccount.new if ma.blank?
	        ma.name = name
	        ma.account_type = "facebook"
	        #个人
	        ma.account_category = 1
	        ma.account = row["facebook_url"]
	        ma.status = 1
	        ma.save
	      end
        if !row["linkedin_url"].blank?
	        ma = SocialAccount.find_by(:account=>row["linkedin_url"])
	        ma = SocialAccount.new if ma.blank?
	        ma.name = name
	        ma.account_type = "linkedin"
	        #个人
	        ma.account_category = 1
	        ma.account = row["linkedin_url"]
	        ma.status = 1
	        ma.save
	      end
      end
    end 
	end

	def self.import_organization_datas(path="#{Rails.root}/organizations.csv")
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
        next if (!row.has_key?"twitter_url")&&(!row.has_key?"facebook_url")&&(!row.has_key?"linkedin_url")
        name = row["company_name"].to_s.strip
        puts i
	      if !row["twitter_url"].blank?
	        ma = SocialAccount.find_by(:account=>row["twitter_url"])
	        ma = SocialAccount.new if ma.blank?
	        ma.name = name
	        ma.account_type = "twitter"
	        #个人
	        ma.account_category = 0
	        ma.account = row["twitter_url"]
	        ma.status = 1
	        ma.save
	      end
	      if !row["facebook_url"].blank?
	        ma = SocialAccount.find_by(:account=>row["facebook_url"])
	        ma = SocialAccount.new if ma.blank?
	        ma.name = name
	        ma.account_type = "facebook"
	        #个人
	        ma.account_category = 0
	        ma.account = row["facebook_url"]
	        ma.status = 1
	        ma.save
	      end
        if !row["linkedin_url"].blank?
	        ma = SocialAccount.find_by(:account=>row["linkedin_url"])
	        ma = SocialAccount.new if ma.blank?
	        ma.name = name
	        ma.account_type = "linkedin"
	        #个人
	        ma.account_category = 0
	        ma.account = row["linkedin_url"]
	        ma.status = 1
	        ma.save
	      end
      end
    end 
	end

  def self.statuses
    {0=>"停止",1=>"采集中"}
  end

  def status_cn
    SocialAccount.statuses[self.status]
  end

  def self.account_categories
    {0=>"组织",1=>"人物"}
  end

  def account_category_cn
    SocialAccount.account_categories[self.account_category]
  end

end
