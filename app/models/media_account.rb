# == Schema Information
#
# Table name: media_accounts
#
#  id           :integer          not null, primary key
#  name         :string
#  account_type :string
#  account      :string
#  status       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MediaAccount < ApplicationRecord

	def self.init_data(path)
		file = File.read(path)
		json_value = JSON.parse(file)
		json_value.each do |k,v|
			next if (!v.has_key?"fb")&&(!v.has_key?"tw")&&(!v.has_key?"ytb")&&(!v.has_key?"lk")
	  	if !v["fb"].blank? && v["fb"]!="未发现"
	  	  ma = MediaAccount.find_by(account: v["fb"])
	  		ma = MediaAccount.new if ma.blank?
	  		ma.name = k
	  		ma.account_type = "facebook"
	  		ma.account = v["fb"]
	  		ma.status = rand(0..1)
	  		ma.save
	  	end
	  	if !v["tw"].blank? && v["tw"]!="未发现"
	  	  ma = MediaAccount.find_by(account: v["tw"])
	  		ma = MediaAccount.new if ma.blank?
	  		ma.name = k
	  		ma.account_type = "twitter"
	  		ma.account = v["tw"]
	  		ma.status = rand(0..1)
	  		ma.save
	  	end
	  	if !v["ytb"].blank? && v["ytb"]!="未发现"
	  		ma = MediaAccount.find_by(account: v["ytb"])
	  		ma = MediaAccount.new if ma.blank?
	  		ma.name = k
	  		ma.account_type = "youtube"
	  		ma.account = v["ytb"]
	  		ma.status = rand(0..1)
	  		ma.save
	  	end
	  	if !v["lk"].blank? && v["lk"]!="未发现"
	  		ma = MediaAccount.find_by(account: v["lk"])
	  		ma = MediaAccount.new if ma.blank?
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
		MediaAccount.statuses[self.status]
	end
end
