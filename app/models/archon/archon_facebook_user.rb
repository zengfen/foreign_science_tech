class ArchonFacebookUser < ArchonBase
  def self.check_create_tasks(file)
    ids = []

    File.new(file).each do |x|
      next if x.blank?

      ids << x.strip.downcase
    end

    ids.uniq!

    ids.each_slice(3000).each do |temp_ids|
      spider_task = SpiderTask.new(
        spider_id: 141,
        level: 1,
        max_retry_count: 0,
        keyword: temp_ids.join(','),
        special_tag: '',
        status: 0,
        timeout_second: 15,
        task_type: 2,
        is_split: false,
      )
      spider_task.special_tag_transfor_id
      spider_task.save_with_spilt_keywords
      spider_task.start!
    end
  end


  def self.dump_not_exist_user(file)
    ids = []

    File.new(file).each do |x|
      next if x.blank?

      ids << x.strip.downcase
    end

    ids.uniq!


    new_ids = []
    ids.each_slice(3000).each do |temp_ids|
      names = ArchonTwitterUser.select("screen_name_lower").where(screen_name_lower: temp_ids).collect(&:screen_name_lower)

      new_ids += (temp_ids - names)
    end


    out = "dump_#{Time.now.to_i}"

    File.open(out, "w") do |f|
      new_ids.each do |x|
        f.puts x
      end
    end

    out
  end



  # ArchonFacebookUser.dump_data_to_json
  def self.dump_data_to_json
    tag = get_tag
    datas = []
    ArchonFacebookUser.where("education <> ''").limit(10).each do |user|
      facebook_basic = get_facebook_basic
      facebook_post = ArchonFacebookPost.get_facebook_post(user.id, tag)
      oids = facebook_post.map{|x| x[:shareId]}
      facebook_postReply = ArchonFacebookComment.get_facebook_post_reply(oids)
      data = {facebook: {}}
      facebook = {}
      facebook["basic"] = facebook_basic
      facebook["pos"] = facebook_pos
      facebook["postReply"] = facebook_postReply
      datas << data.to_json
    end
    File.open("#{json_file_path}/facebook_data.json", "a+") {|f| f.puts datas}
  end

  def get_facebook_basic
    hometown = JSON.parse(self.hometown) rescue ""
    hometown = hometown.class == Hash ? hometown["name"] : hometown
    education = JSON.parse(self.education).map{|x|
      {
        "startTime": "", #起始时间
        "endTime": "", #结束时间
        "name": (x["school"]["name"] rescue nil), #学校名
        "url": "", #学校链接     (预留)
        "degree": x["type"], #学位
        "others": "", #其他字段
        "fullText": "" #教育情况全文
      }
    }
    work = JSON.parse(self.work).map{|x|
      {
        "startTime": (Time.parse(x["start_date"]).strftime("%Y%m%d%H%M%S") rescue nil), #起始时间
        "endTime": (Time.parse(x["end_date"]).strftime("%Y%m%d%H%M%S") rescue nil), #结束时间
        "name": (x["employer"]["name"] rescue nil), #公司名称
        "url": "", #公司链接    (预留)
        "position": (x["position"]["name"] rescue nil), #职位
        "location": (x["location"]["name"] rescue nil), #工作地点
        "other": "", #其他字段
        "fullText": "" #工作情况全文
      }
    }
    facebook_basic = {
      "userId": self.id, #用户ID，facebook id
      "userName": self.name, #用户名
      "screenName": self.screen_name, #昵称
      "headUrl": "", #string 头像地址,需要采集到本地，不能只有地址
      "website": self.link, #string 个人facebook页面地址
      "about": self.about, #string 简介信息
      "religion": "", #string  宗教
      "birthday": self.birthday, #string  生日
      "politics": "", #string  党派       (预留)
      "interested": (JSON.parse(self.interested_in) rescue nil) , #string  性取向     (预留)
      "marriedStatus": self.relationship_status, #string  婚姻状况   (已婚、未婚、离异、未知)
      "language": (JSON.parse(self.languages).map{|x| x["name"]} rescue []),
      "registerEmail": "", #注册邮箱
      "registerPhones": "", #注册手机号
      "email": "", #string 邮箱
      "mobile": self.phone, #string 手机号
      "allPhones": [#如果存在多个手机号，按如下格式填充
        {"phoneNumber":
           {
             "displayNumber": self.phone, #string 展示号码
             "universalNumber": nil #string 通用号码
           },
         "phoneType": nil #string 电话类型
        }
      ],
      "currentCity": "", #string 城市名，现居住城市
      "hometown": hometown, #string 城市名，家乡
      "quotes": nil, #string 座右铭
      #教育情况（起始时间、结束时间、学校名、学校链接、学校图标URL、学位、其他字段、教育情况全文）、居住地、学校、职业等
      "education": education,
      #工作情况（起始时间、结束时间、公司名称、公司链接、公司图标链接、职位、工作地点、说明、其他字段（工作情况所有描述信息）
      "work": work,
    }
  end


  def get_tag
    252
  end

  # 存储
  def self.tag_post_ids(tag = 252)
    ArchonFacebookPostTag.where(tag: tag).find_each do |x|
      $redis.sadd("archon_center_#{tag}_facebbok_post_ids", x.pid)
    end
  end

  # 文件存储路径
  def self.json_file_path
    path = "#{Rails.root}/public/json_datas"
    unless Dir.exists? path
      FileUtils.mkdir_p path
    end
    return path
  end
end
