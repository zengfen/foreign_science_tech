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




  def self.dump_data_to_json
    datas = []
    ArchonFacebookUser.where("education <> ''").limit(10).each do |user|
      facebook_basic = get_facebook_basic
      facebook_post = get_facebook_post
      oids = facebook_post.map{|x| x["shareId"]}
      facebook_postReply = get_facebook_post_reply(oids)
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
    honmetown = hometown.class == Hash ? hometown["name"] : hometown
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
        "startTime": (Time.parse(x["start_date"]).strftime("%Y%m%dT%H%M") rescue null), #起始时间
        "endTime": (Time.parse(x["end_date"]).strftime("%Y%m%dT%H%M") rescue null), #结束时间
        "name": (x["employer"]["name"] rescue null), #公司名称
        "url": "", #公司链接    (预留)
        "position": (x["position"]["name"] rescue null), #职位
        "location": (x["location"]["name"] rescue null), #工作地点
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
      "interested": (JSON.parse(self.interested_in) rescue null) , #string  性取向     (预留)
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
             "universalNumber": null #string 通用号码
           },
         "phoneType": null #string 电话类型
        }
      ],
      "currentCity": "", #string 城市名，现居住城市
      "hometown": hometown, #string 城市名，家乡
      "quotes": null, #string 座右铭
      #教育情况（起始时间、结束时间、学校名、学校链接、学校图标URL、学位、其他字段、教育情况全文）、居住地、学校、职业等
      "education": education,
      #工作情况（起始时间、结束时间、公司名称、公司链接、公司图标链接、职位、工作地点、说明、其他字段（工作情况所有描述信息）
      "work": work,
    }
  end

  def get_facebook_post
    tag = get_tag
    facebook_post = []
    count = 0
    self.archon_facebook_post.find_each do |x|
      # 若这条post的tag不为指定tag 则取下一条数据
      next if !$redis.sismember("archon_center_#{tag}_facebbok_post_ids", x.id)
      count += 1
      # 只取10条数据
      break if count > 10
      facebook_post << {
        #发布者信息
        "userId": x.user_id, #分享者ID（用来进行关联）
        "userScreenName": x.user_screen_name, #分享者昵称
        "userName": x.user_name, #分享者名称
        #文章信息
        "shareId": x.oid, #分享ID（用来进行分享与用户关联）
        "shareContent": x.title, #分享内容
        "mediaUrl": (JSON.parse(x.images) rescue []) + (JSON.parse(x.videos) rescue []), #分享的照片/视频URL
        "mentionUsers": [#文章中提及到的Facebook用户
          {
            "userId": "", # int facebook用户ID
            "userName": "", #string 姓名"
          }
        ],
        "shareTime": (Time.at(x.created_time).strftime("%Y%m%dT%H%M") rescue null), #分享时间
        "location": {#分享位置
                     "latitude": nil,
                     "longitude": nil,
                     "address": nil
        },
        "likeCount": x.like_count, #赞次数
        "replyCount": x.comment_count, #评论次数
        "forwardCount": x.repost_count, #转发次数
        "shareType": x.post_type, #分享类型
        "visitUrl": x.source_url, #原文信息URL
        "publishTime": "20160517081236", #发布时间，格式：yyyyMMddHHmmss
        "updatedTime": "20160517081236", #更新时间，格式：yyyyMMddHHmmss
        "tags": [tag] #文章的标签
      }
    end

    return facebook_post
  end

  def get_facebook_post_reply(oids)
    facebook_postReply = []
    ArchonFacebookTComment.where(post_oid:oids).limit(20).each do |x|
      facebook_postReply << {
        "shareId": x.oid, #分享ID （唯一标定回复信息）
        "parentID": x.post_oid, #回复父ID，用于采集回复的回复
        "replyID": x.id, #回复ID
        "replyContent": x.title, #回复内容
        "mediaUrl": (JSON.parse(x.images) rescue []) + (JSON.parse(x.videos) rescue []), #回复的视频或图片的URL
        "replyTime": "", #回复时间
        "userId": x.user_id, #回复者ID
        "userScreenName": x.user_screen_name, #回复者昵称
        "headUrl": "", #回复者头像
      }
    end
    return facebook_postReply
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
