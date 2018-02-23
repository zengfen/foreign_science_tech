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
#  sc         :string           源代码
#  slg        :string           语言
#  fmt        :string           源类型
#  sn         :string           源名称
#  asn        :string           源名称-当地语言
#  dn         :string           目录名称
#  std        :string           数据状态
#  dsd        :string           停止日期
#  lva        :string           覆盖类型-文章级别
#  lvs        :string           覆盖类型-源级别
#  od         :string           上线日期
#  fio        :string           线上首次发布日期
#  de         :string           描述 - 英语
#  dea        :string           描述 - 当地语言
#  frp        :string           发布频率
#  lag        :string           线上可获取目标
#  upn        :string           更新计划
#  ntx        :string           外部日记
#  pip        :string           伪IP
#  url        :string           源网页地址 
#  pbc        :string           发行商代码
#  pub        :string           发行商
#  lgo        :string           媒体标志
#  cir        :string           发行量 
#  cis        :string           发行量源代码
#  csn        :string           发行源名称
#  rst        :string           RST价值 (源组)
#  pst        :string           一级源类型代码
#  psd        :string           一级源类型
#  sfg        :string           源父组代码
#  roo        :string           原产地组代码
#  mri        :string           线上最新发布日期
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
