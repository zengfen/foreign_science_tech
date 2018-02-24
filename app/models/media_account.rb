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

  def self.load_files(root_path)
    Find.find(root_path) do |path|  
      next unless %(xlsx xls csv).include?(path.split(".").last.downcase)
      load_one_file(path) 
    end 
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
      count = 0
      ss.sheets.each do |s|
      ss.default_sheet = s
      header = ss.row(2).collect{|x| (x.is_a?String)?x.gsub(' ',''):""}
      for i in (ss.first_row+2)..ss.last_row
        row = Hash[[header, ss.row(i)].transpose]
        hash = {}
        hash[:sc] = row["SourceCode(sc)"].to_s.strip
        hash[:slg] = row["Language(slg)"].to_s.strip
        hash[:fmt] = row["SourceType(fmt)"].to_s.strip
        hash[:sn] = row["SourceName(sn)"].to_s.strip
        hash[:asn] = row["SourceName-NativeLanguage(asn)"].to_s.strip
        hash[:dn] = row["DirectoryName(dn)"].to_s.strip
        hash[:std] = row["StatusName(std)"].to_s.strip
        hash[:dsd] = row["DiscontinuedDate(dsd)"].to_s.strip
        hash[:lva] = row["TypeofCoverage-ArticleLevel(lva)"].to_s.strip
        hash[:lvs] = row["TypeofCoverage-SourceLevel(lvs)"].to_s.strip
        hash[:od] = row["OnlineDate(od)"].to_s.strip
        hash[:fio] = row["FirstIssueOnline(fio)"].to_s.strip
        hash[:de] = row["Description-EnglishLanguage(de)"].to_s.strip
        hash[:dea] = row["Description-NativeLanguage(dea)"].to_s.strip
        hash[:frp] = row["Frequency(frp)"].to_s.strip
        hash[:lag] = row["OnlineAvailabilityTarget(lag)"].to_s.strip
        hash[:upn] = row["UpdateSchedule(upn)"].to_s.strip
        hash[:ntx] = row["ExternalNotes(ntx)"].to_s.strip
        hash[:pip] = row["Pseudo-IP(pip)"].to_s.strip
        hash[:url] = row["SourceWebSiteAddress(url)"].to_s.strip
        hash[:pbc] = row["PublisherCode(pbc)"].to_s.strip
        hash[:pub] = row["Publisher(pub)"].to_s.strip
        hash[:lgo] = row["Logo(lgo)"].to_s.strip
        hash[:cir] = row["Circulation(cir)"].to_s.strip
        hash[:cis] = row["CirculationSourceCode(cis)"].to_s.strip
        hash[:csn] = row["CirculationSourceName(csn)"].to_s.strip
        hash[:rst] = row["RSTValues(SourceGroup)(rst)"].to_s.strip
        hash[:pst] = row["PrimarySourceTypeCode(pst)"].to_s.strip
        hash[:psd] = row["PrimarySourceType(psd)"].to_s.strip
        hash[:sfg] = row["SourceFamilyGroupCode(sfg)"].to_s.strip
        hash[:roo] = row["RegionofOriginGroupCode(roo)"].to_s.strip
        hash[:mri] = row["MostRecentIssueOnline(mri)"].to_s.strip.to_i.to_s
        next if hash[:sc].blank?
        ma = MediaAccount.find_by(:sc=>hash[:sc])
        next if ma.present?
        hash[:name] = hash[:sn]
        hash[:short_name] = hash[:sn]
        count +=1 if MediaAccount.create(hash)
      end
    end 
    puts "path: #{path} count:#{count} row:#{ss.last_row-2}"
  end


end
