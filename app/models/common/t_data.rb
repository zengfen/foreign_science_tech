# data_id 数据ID
# data_address 数据地址(url)
# website_name 网站名称
# data_spidername 爬虫名称(关联website)  全部的源代码
# data_snapshot_path 快照路径 即 带标签正文 即res.body
# data_source_type 数据源类型（website、wechat、other） 固定为 website
# data_mode 采集方式（spider、upload）
# data_time 采集时间
# con_title 标题
# con_from 来源
# con_author 作者
# con_time 发布时间
# con_text 正文
# category 文本类别
# attached_media_info 媒体附件信息
# attached_img_info 图片附件信息
# attached_file_info 文档附件信息

class TData < CommonBase
  self.table_name = "t_data"

  after_destroy :delete_redis_data
  after_save :update_author_counter

  def self.link_exist?(link)
    key = TData.t_datas_key
    md5_id = Digest::MD5.hexdigest(link)
    if $redis.sismember(key, md5_id)
      return true
    else
      return false
    end
  end

  def self.save_one(task)
    a = TData.new
    a.data_address = task[:data_address]
    a.website_name = task[:website_name]
    a.data_spidername = task[:data_spidername]
    a.data_snapshot_path = task[:data_snapshot_path]
    a.data_time = Time.now
    a.con_title = task[:con_title]
    a.con_from = task[:con_from]
    a.con_author = task[:con_author]
    a.con_time = task[:con_time]
    a.con_text = task[:con_text]
    a.category = task[:category]
    a.attached_media_info = task[:attached_media_info]
    a.attached_img_info = task[:attached_img_info]
    a.attached_file_info = task[:attached_file_info]
    a.data_source_type = "website"
    a.data_mode = "spider"

    key = TData.t_datas_key
    md5_id = Digest::MD5.hexdigest(a.data_address)
    if $redis.sismember(key, md5_id)
      return {type: "success", message: "数据已存在"}
    end


    # 1、标题不为空，正文内容为空的（文字 视频 音频 文件都没有），可将正文内容设置为空字符串入库；
    # 2、标题不为空，正文内容为文字 视频 音频 文件 中的任何一项或多项，都需要进行采集；
    # 3、标题为空，正文内容不为空，可将标题内容设置为空字符串入库；

    error_message = nil
    if a.website_name.blank?
      error_message = "website_name is nil"
    end
    if a.data_address.blank?
      error_message = "data_address is nil"
    end
    if a.con_title.blank? && a.con_text.blank? && a.attached_media_info.blank? && a.attached_img_info.blank? && a.attached_file_info.blank?
      error_message = "con_title con_text attached_media_info attached_img_info attached_file_info are all nil"
    end
    if a.con_time.to_i > Time.now.to_i
      error_message = "时间大于当前"
    end
    if task[:con_author].present? && task[:con_author].class != Array
      error_message = "作者需数组类型"
    end

    if error_message.present?
      return {type: "error", message: error_message}
    end

    begin
      if a.save
        $redis.sadd(key, md5_id)
        # AuthorCounter.process_author(task[:con_author],a.con_time) if task[:con_author].present?
        return {type: "success"}
      else
        return {type: "error", message: a.errors.full_messages}
      end
    rescue Exception => e
      return {type: "error", message: e.message.to_s[0...300]}
    end

    return {type: "success"}
  end


  def self.t_datas_key
    "foreign_sci_tec_t_datas_key"
  end


  def delete_redis_data
    key = TData.t_datas_key
    md5_id = Digest::MD5.hexdigest(self.data_address)
    $redis.srem(key, md5_id)
  end

  # TData.create_table
  def self.create_table
    files = ["t_data.sql", "t_log_spider.sql", "t_sk_job_instance.sql"]
    files.each do |file|
      `bundle exec rails db < "#{Rails.root}/public/sql/#{file}"`
    end
  end


  def self.during(start_date, end_date)
    self.where(data_time: (start_date..end_date.end_of_day))
  end

  def self.during_con_time(start_date, end_date)
    self.where(con_time: (start_date..end_date.end_of_day))
  end

  def update_author_counter
    authors = JSON.parse(self.con_author) rescue nil
    return if authors.blank?
    date = self.con_time.to_date
    authors.each do |author|
      data = AuthorCounter.where(con_author: author).where(con_date: date).first
      if data.present?
        data.update(count: data.count + 1)
      else
        AuthorCounter.create(con_author: author, con_date: date, count: 1)
      end
    end
  end

  def self.to_csv
    # CSV.generate do |csv|
    #   csv << column_names
    #   all.each do |data|
    #     csv << data.attributes.values_at(*column_names)
    #   end
    # end
    head = 'EF BB BF'.split(' ').map { |a| a.hex.chr }.join()
    CSV.generate(outfile= head) do |csv|
      new_column_names = column_names - ["data_snapshot_path"]
      csv << new_column_names
      all.each do |data|
        csv << data.attributes.values_at(*new_column_names)
      end
    end

  end


  # nohup rails r TData.import_datas &
  def self.import_datas
    # a = ["/Users/zengfen/Downloads/t_data历史数据/all_json/ReutersComEnergy.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/NikkeiComDriverless.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/NytimesComClimate.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/ThevergeCom.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/NikkeiComLeadingEdge.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/BlogsAkamaiCom.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/AbcNetAuScience.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/LemondeFrCosmos.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/.DS_Store", "/Users/zengfen/Downloads/t_data历史数据/all_json/NikkeiComAi.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/SmhComAuTechnology.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/LemondeFrArcheologie.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/LemondeFrMedecine.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/PcmagazineCoIl.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/PcmagazineCoIlCategory.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/NikkeiComFintech.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/ReutersComScience.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/NikkeiComMobile.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/NikkeiComEnergy.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/NytimesComSpace.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/TheguardianComScience.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/TheguardianComTech.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/LemondeFrPaleontologie.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/ReutersComMedia.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/NikkeiComIot.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/NytimesComPersonaltech.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/GobMx.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/VenturebeatComAi.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/LemondeFrEspace.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/CbcCaTechnology.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/LemondeFr.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/IafOrgIl.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/WashingtonpostCom.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/AfricantechnologyforumOrg.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/ReutersCom.json", "/Users/zengfen/Downloads/t_data历史数据/all_json/AustinforumOrg.json"]
    file_path = "/Users/zengfen/Downloads/t_data历史数据/all_json_2"
    a = []
    Dir.foreach(file_path) do |file|
      next if file == "." || file == ".."
      file_name = file_path+"/"+file
      a << file_name
    end
    puts a

    a.each do |file|
      datas = []
      index = 0
      File.open(file, "r") do |f|
        while data = f.gets
          index += 1
          puts "index=======#{index}"
          data = JSON.parse(data) rescue nil
          next if data.blank?
          data["con_author"] = data["con_author"].to_json if data["con_author"].class == Array
          data["attached_media_info"] = data["attached_media_info"].to_json if data["attached_media_info"].class == Array
          data["attached_img_info"] = data["attached_img_info"].to_json if data["attached_img_info"].class == Array
          data["attached_file_info"] = data["attached_file_info"].to_json if data["attached_file_info"].class == Array
          data["data_time"] = Time.now
          data["data_source_type"] = "website"
          data["data_mode"] = "spider"
          data["data_snapshot_path"] = data["data_snapshot_path"][0...65535]
          datas << data
          if datas.count >= 10
            destination_columns = datas.first.keys
            TData.bulk_insert(*destination_columns, ignore: true, set_size: 10) do |worker|
              datas.each do |data|
                worker.add(data)
              end
            end
            # TData.create(datas)
            datas = []
          end
        end
      end
      destination_columns = datas.first.keys

      # all_address = datas.map{|x| x["data_address"]}
      # have = TData.where(data_address:all_address).pluck(:data_address)
      # none = all_address - have
      # datas = datas.find_all{|k| none.include? k["data_address"]}
      # puts "=======datas=======#{datas.count}"

      TData.bulk_insert(*destination_columns, ignore: true, set_size: 10) do |worker|
        datas.each do |data|
          worker.add(data)
        end
      end
    end


  end


end
