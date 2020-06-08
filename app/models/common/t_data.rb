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
      return {type:"success",message:"数据已存在"}
    end

    error_message = nil
    if a.con_title.blank?
      error_message = "con_title is nil"
    end
    if a.website_name.blank?
      error_message = "website_name is nil"
    end
    if a.data_address.blank?
      error_message = "data_address is nil"
    end
    if a.con_text.blank? && a.attached_file_info.blank?
      error_message = "con_text and attached_file_info is nil"
    end
    if a.con_time.blank?
      error_message = "时间为空"
    end
    if a.con_time.to_i > Time.now.to_i
      error_message = "时间大于当前"
    end
    if task[:con_author].present? && task[:con_author].class != Array
      error_message = "作者需数组类型"
    end

    if error_message.present?
      return {type:"error",message:error_message}
    end

    if a.save
      $redis.sadd(key, md5_id)
      # AuthorCounter.process_author(task[:con_author],a.con_time) if task[:con_author].present?
      return {type:"success"}
    else
      return {type:"error",message:a.errors.full_messages}
    end
    return {type:"success"}
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
    self.where(con_time: (start_date..end_date.end_of_day))
  end

  def update_author_counter
    authors = JSON.parse(self.con_author) rescue nil
    return if authors.blank?
    date = self.con_time.to_date
    authors.each do |author|
      data = AuthorCounter.where(con_author:author).where(con_date:date).first
      if data.present?
        data.update(count:data.count + 1)
      else
        AuthorCounter.create(con_author:author,con_date:date,count:1)
      end
    end
  end


end
