# == Schema Information
#
# Table name: social_accounts
#
#  id           :integer          not null, primary key
#  name         :string
#  account_type :string
#  account      :string
#  status       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class SocialAccount < ApplicationRecord

  def self.import_data
    max_count = File.open("#{Rails.root}/tmp/people.csv").readlines.count
    File.open("#{Rails.root}/tmp/people.csv").readlines.each_with_index do |line,i|
      next if i == 0
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

  def self.statuses
    {0=>"停止",1=>"采集中"}
  end

  def status_cn
    SocialAccount.statuses[self.status]
  end
end
