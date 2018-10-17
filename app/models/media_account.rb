# == Schema Information
#
# Table name: media_accounts
#
#  id         :bigint(8)        not null, primary key
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

class MediaAccount <  ActiveRecord::Base
  # self.abstract_class = true
  establish_connection MediaDB

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
        hash[:dsd] = row["DiscontinuedDate(dsd)"].to_s.strip.to_i.to_s
        hash[:lva] = row["TypeofCoverage-ArticleLevel(lva)"].to_s.strip
        hash[:lvs] = row["TypeofCoverage-SourceLevel(lvs)"].to_s.strip
        hash[:od] = row["OnlineDate(od)"].to_s.strip.to_i.to_s
        hash[:fio] = row["FirstIssueOnline(fio)"].to_s.strip.to_i.to_s
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

  def self.create_index
    $elastic = EsConnect.client
    if !($elastic.indices.exists? index: "media_accounts")
      $elastic.indices.create index: "media_accounts", body: {
        settings: {
          index: {
            number_of_shards: 10,
            number_of_replicas: 1
          }
        },
        mappings: {
          media_accounts: {
            _all: {
              analyzer: "ik_max_word",
              search_analyzer: "ik_max_word",
            },
            properties: {
              data_id:{type: 'integer',index:'not_analyzed'},#db id
              name:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #名称
              short_name:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #简称
              account:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #账号
              status:{type: 'integer',index:'not_analyzed'}, #状态
              sc:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #源代码
              slg:{type: 'keyword',index:'not_analyzed'}, #语言
              fmt:{type: 'keyword',index:'not_analyzed'}, #源类型
              sn:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #源名称
              asn:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #源名称-当地语言
              dn:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #目录名称
              std:{type: 'keyword',index:'not_analyzed'}, #数据状态
              dsd:{type: 'date',index:'not_analyzed'}, #停止日期
              lva:{type: 'keyword',index:'not_analyzed'}, #覆盖类型-文章级别
              lvs:{type: 'keyword',index:'not_analyzed'}, #覆盖类型-源级别
              od:{type: 'date',index:'not_analyzed'}, #上线日期
              fio:{type: 'date',index:'not_analyzed'}, #线上首次发布日期
              de:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #描述 - 英语
              dea:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #描述 - 当地语言
              frp:{type: 'keyword',index:'not_analyzed'}, #发布频率
              lag:{type: 'keyword',index:'not_analyzed'}, #线上可获取目标
              upn:{type: 'keyword',index:'not_analyzed'}, #更新计划
              ntx:{type: 'keyword',index:'not_analyzed'}, #外部日记
              pip:{type: 'keyword',index:'not_analyzed'}, #伪IP
              url:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #源网页地址
              pbc:{type: 'keyword',index:'not_analyzed'}, #发行商代码
              pub:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #发行商
              lgo:{type: 'keyword',index:'not_analyzed'}, #媒体标志
              cir:{type: 'integer',index:'not_analyzed'}, #发行量
              cis:{type: 'keyword',index:'not_analyzed'}, #发行量源代码
              csn:{type: 'text', analyzer: 'ik_max_word',search_analyzer: "ik_max_word" }, #发行源名称
              rst:{type: 'keyword',index:'not_analyzed'}, #RST价值 (源组)
              pst:{type: 'keyword',index:'not_analyzed'}, #一级源类型代码
              psd:{type: 'keyword',index:'not_analyzed'}, #一级源类型
              sfg:{type: 'keyword',index:'not_analyzed'}, #源父组代码
              roo:{type: 'keyword',index:'not_analyzed'}, #原产地组代码
              mri:{type: 'date',index:'not_analyzed'} #线上最新发布日期
            }
          }
        }
      }
    end
  end
  def self.load_data_to_es
    $elastic = EsConnect.client
    MediaAccount.find_in_batches do |datas|
      body = []
      datas.each do |r|
        begin
          tmp = { index: { _index:"media_accounts", _type: "media_accounts", _id: r.id, data: {
                             data_id: r.id,#db id
                             name:r.name, #名称
                             short_name:r.short_name, #简称
                             account:r.account, #账号
                             status:r.status, #状态
                             sc:r.sc, #源代码
                             slg:r.slg, #语言
                             fmt:r.fmt, #源类型
                             sn:r.sn, #源名称
                             asn:r.asn, #源名称-当地语言
                             dn:r.dn, #目录名称
                             std:r.std, #数据状态
                             dsd:r.dsd.blank? ? nil : r.dsd.to_i.to_s, #停止日期
                             lva:r.lva, #覆盖类型-文章级别
                             lvs:r.lvs, #覆盖类型-源级别
                             od:r.od.blank? ? nil : r.od.to_i.to_s, #上线日期
                             fio:r.fio.blank? ? nil : r.fio.to_i.to_s, #线上首次发布日期
                             de:r.de, #描述 - 英语
                             dea:r.dea, #描述 - 当地语言
                             frp:r.frp, #发布频率
                             lag:r.lag, #线上可获取目标
                             upn:r.upn, #更新计划
                             ntx:r.ntx, #外部日记
                             pip:r.pip, #伪IP
                             url:r.url, #源网页地址
                             pbc:r.pbc, #发行商代码
                             pub:r.pub, #发行商
                             lgo:r.lgo, #媒体标志
                             cir:r.cir.to_i, #发行量
                             cis:r.cis, #发行量源代码
                             csn:r.csn, #发行源名称
                             rst:r.rst, #RST价值 (源组)
                             pst:r.pst, #一级源类型代码
                             psd:r.psd, #一级源类型
                             sfg:r.sfg, #源父组代码
                             roo:r.roo, #原产地组代码
                             mri:r.mri.blank? ? nil : r.mri #线上最新发布日期
          } } }
          body << tmp
        rescue Exception => e
          puts e
          puts r.inspect
          break
        end
      end
      return nil if body.blank?
      begin
        puts $elastic.bulk body: body
      rescue Exception=>e
        puts e
        break
      end
    end
  end

  def self.get_aggs_opts
    elastic = EsConnect.client
    hash = {}
    res = elastic.search index:"media_accounts",body:{size:0,query:{},
                                                      aggs:{
                                                        slg:{terms:{field:'slg',size:100}},
                                                        fmt:{terms:{field:'fmt',size:100}},
                                                      }
                                                      }
    res["aggregations"].each do |k,v|
      values = v["buckets"].collect{|x| x["key"]} rescue []
      hash[k] =  values.sort unless values.blank?
    end

    return hash

  end

  def load_to_es
    doc = JSON.parse(self.to_json)
    doc.merge!({"data_id":self.id}).delete_if{|key,value| ["id","created_at","updated_at"].include?key}
    doc["dsd"] = nil  if self.dsd.blank?||self.dsd.to_i==0
    doc["od"] = nil   if self.od.blank?||self.od.to_i==0
    doc["fio"] = nil  if self.fio.blank?||self.fio.to_i==0
    doc["cir"] = self.cir.to_i
    elastic = EsConnect.client
    elastic.update index: "media_accounts", type: "media_accounts",id:self.id,body: {doc:doc}
  end

  def self.daily_update
    source_codes = self.pluck(:sc).uniq

    elastic = EsConnect.client

    index_name  = "information_records_" + (Time.now - 1.day).strftime("%Y%m")

    gte_time = Time.parse((Time.now-1.day).strftime("%Y-%m-%d 00:00:00"))

    lte_time = Time.parse((Time.now-1.day).strftime("%Y-%m-%d 23:59:59"))

    results = elastic.search index:"#{index_name}",body:{
      size:0,
      query:{bool:{must:[
                     {range:{created_time:{gte:gte_time,lte:lte_time}}},
                     #{terms:{sns_uid:source_codes}}
      ]}},
      aggregations:{sns_uid:{terms:{field:"sns_uid",size:100000}
                             }}
    }

    total_count = results["aggregations"]["sns_uid"]["buckets"].count

    results["aggregations"]["sns_uid"]["buckets"].each_with_index do |record,index|
      puts "-----------------------------index:#{index},total_count:#{total_count}"
      if source_codes.include?(record["key"])
        update_one_record(elastic,index_name,record["key"])
      end
    end
  end

  def self.update_one_record(elastic,index_name,key)
    result = elastic.search index: index_name, body: {
      size:1,
      sort:{created_time:'desc'},
      query:{
        bool:{
          must:[
            {term:{sns_uid:key}}
      ]}}
    }
    time = result["hits"]["hits"][0]["_source"]["created_time"] if result["hits"]["hits"].count > 0
    date = Time.parse(time).strftime("%Y%m%d")
    ma = MediaAccount.find_by_sc(key)
    ma.mri = date
    ma.save
    ma.load_to_es
  end

end
