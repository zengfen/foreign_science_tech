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

  def user_names
    "aleksandra.pitner,ronald.l.moolenaar,cynthia.a.griffin.7,adrienne.p.fuentes,terry.pitner,TerryBranstad,robert.forden,miles.toder,shane.krohne,ben.glerum.5,zach.alger,ory.abramowicz,jimmullinax,clark.ledger,keithlommel,gbenelisha,cannon.smith,lizzie,18803355,drew.wind,being.alan.clark,nathaniel.tishman,levin.flake,jenniferkallen,JustinWalls,100005248428114,vicki.ting.56,danielle.koschil,boolbada,danchops,baylor.duncan,roseanne.freese,joe.plunkett,chelsea.chris.fisher,jfouss,michael.dubray,luke.donohue.754,Jesse.Curtis.702,ryan.mckean,mark.petry,russell.caplen,carla.hitchcock,chris.miller.127648,jing.w.edwards,christian.marchant.12,shelby.p.martin.5,james.cunningham.771282,100009568373676,dante.paradiso.50,kurt.tong.3,darragh.paradiso,brittanie.lakemaffeo,jeffrey.shrader".split(",")
  end



  # ArchonFacebookUser.dump_data_to_json
  def self.dump_data_to_json
    user_names = user_names
    tag = get_tag
    datas = []
    unknow_hash = self.unknow_hash
    count = 0

    file_path = "#{Rails.root}/public/json_datas/201901010129_facebook_source_data.json"
    user_id_datas = []
    File.open(file_path, "r") do |f|
      while data  = f.gets
        user_id_datas << JSON.parse(data)
      end
    end
    user_ids = user_id_datas.map{|x| x["uid"]}

    # ArchonFacebookUser.where(screen_name: user_names) do |user|
    ArchonFacebookUser.where(id: user_ids).each do |user|
      friend_ids = user_id_datas.find{|x| x["uid"].to_i == user.id}["friends"].map{|x| x["id"]} rescue []
      friends = get_friends(friend_ids)
      facebook_basic = user.get_facebook_basic
      facebook_post = ArchonFacebookPost.get_facebook_post(user.id, tag)
      # next if facebook_post.blank?
      oids = facebook_post.map{|x| x[:shareId]}
      facebook_postReply = ArchonFacebookComment.get_facebook_post_reply(oids)
      # count += 1
      # break if count > facebook_user_size
      data = {facebook: {}}
      facebook = {}
      facebook["basic"] = facebook_basic
      facebook["friends"] = friends
      facebook["post"] = facebook_post
      facebook["postReply"] = facebook_postReply
      data[:facebook] = facebook.merge(unknow_hash)
      # datas << data.to_json
      $redis.sadd("archon_center_facebook_datas", data.to_json)
    end
  end

  # nohup rails r ArchonFacebookUser.read_redis_to_file &
  def self.read_redis_to_file
    time = Time.now.strftime("%Y%m%d%H%M%S")
    while true
      datas = []
      200.times do
        data = $redis.spop("archon_center_facebook_datas")
        break if data.blank?
        datas << data
      end
      break if datas.blank?
      File.open("#{json_file_path}/#{time}_facebook_data.json", "a+") {|f| f.puts datas}
    end
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
    } rescue nil
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
    } rescue nil
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
      #除了现居地和家乡，其他居住过的地方(起始时间、结束时间、生活过的地方名称、生活过的地方链接、生活过的地方图标链接、生活过的地方说明)
      "living": [
        {
          "startTime": "", #起始时间
          "endTime": "", #结束时间
          "name": "", #生活过的地方名称
          "other": "", #其他字段
          "fullText": "" #生活情况全文
        }
      ],
    }
  end

  def self.get_friends(user_ids)
    friends = []
    self.where(id:user_ids).each do |x|
      #好友列表
      friends <<
        {
          "userId": x.id, # int facebook用户ID
          "userName": x.name, #string 姓名
          "profileImage": "", #头像
          "friendTag": [""], #好友标签
        }
    end
    return friends
  end

  def self.unknow_hash
    {# 家庭成员列表
     "familyMember": [
       {
         "userId": "", # int facebook用户ID
         "userName": "", #string 姓名
         "profileImage": "", #头像
         "relationship": "" #string 家庭关系
       },
     ],
     #关注
     "followerUser": [#被追随人的ID见basic部分
       {
         "userId": "", #追随者ID（用于标定用户与追随者的关系）
         "userName": "", #追随者名称
         "userScreenName": "", #追随者昵称
         "headPhoto": "", #追随者头像内容
       }
     ],
     #粉丝
     "followedUser": [#被追随人的ID见basic部分
       {
         "userId": "", #追随者ID（用于标定用户与追随者的关系）
         "userName": "", #追随者名称
         "userScreenName": "", #追随者昵称
         "headPhoto": "", #追随者头像内容
       }
     ],
     #分享的点赞信息   目前没有
     "postLikes": [
       {
         "shareId": "", #分享ID （唯一标定分享内容)
         "userId": "", #点赞者ID（用于标定点赞者与分享的关系）
         "userScreenName": "", #点赞者昵称
         "headUrl": "", #点赞者头像
         "pubTime": "" #点赞时间
       }
     ],
     #群组成员  目前没有
     "groupsMember": [
       {
         "groupId": "", #群组ID（用于标定群组与群组成员的关系）
         "groupName": "", #群组名称
         "userId": "", #群组成员ID（用于标定群组与群组成员的关系）
         "userName": "", #群组成员名称
         "userScreen": "", #群组成员昵称
         "headUrl": "", #群组成员头像内容
         "createTime": "" #邀请时间
       }
     ],
     #群组内发表的分享  目前没有
     "groupsPost": [
       {
         "groupId": "", #群组ID（用于标定分享内容与群组的关系）
         "groupName": "", #群组名称
         "shareId": "", #分享ID（用于标定分享内容与分享者的关系）
         "shareContent": "", #分享内容
         "mediaUrl": "", #分享的照片/视频URL
         "shareType": "", #分享类型
         "userId": "", #分享者ID（用于标定分享内容与分享者的关系）
         "userName": "", #分享者名称
         "headUrl": "", #群组成员头像内容
         "createTime": "", #分享时间
         "location": "" #分享位置
       }
     ],
     #点赞    目前没有
     "like": [#被点赞人的ID见basic部分
       {
         "userId": "", #点赞者ID（用于标定用户与追随者的关系）
         "userName": "", #点赞者名称
         "userScreenName": "", #点赞者昵称
         "headPhoto": "", #点赞者头像内容
       }
     ],
     #活动    目前没有
     "event": [
       {
         "eventId": "", #活动ID（用于标定活动与创建者的关系）
         "eventName": "", #活动名称
         "userId": "", #创建用户ID（用于标定活动与创建者的关系）
         "userName": "", #创建用户名称
         "userScreenName": "", #创建用户昵称
         "startTime": "", #活动开始日期和时间
         "eventBody": "", #活动内容
         "eventLocation": "" #活动地点
       }
     ],
     #活动成员  目前没有
     "eventMember": [
       {
         "eventId": "", #活动ID（唯一标定活动）
         "userId": "", #活动成员ID（用于标定活动与成员的关系）
         "userName": "", #成员名称
         "userPhoto": "", #活动成员头像内容
       }
     ],
     #活动分享  目前没有
     "eventPost": [
       {
         "eventId": "", #分享处的活动ID（用于标定分享与活动的关系）
         "shareId": "", #分享ID（用于标定分享与分享者的关系）
         "shareType": "", #分享类型
         "shareContent": "", #分享内容
         "mediaUrl": "", #分享的照片/视频URL
         "location": "", #分享位置
         "userId": "", #分享者ID（用于标定分享与分享者的关系）
         "userName": "", #分享者名称
         "replyCount": "", #评论次数
         "forwardCount": "", #转发次数
         "likeCount": "", #赞次数
         "createTime": "", #分享时间
       }
     ],
     #签到    目前没有
     "checkIn": [
       {
         "url": nil, #string 地址
         "location": {#经纬度和地址
                      "latitude": nil,
                      "longitude": nil,
                      "address": nil
         },
         "checkInTime": nil, #签到时间
       }
     ],
     # 部分有 user
     "others": {
       #其他非重要信息，属于预留字段；比如movies,music,videos,book,game,game_score。
       #电影
       "movies": [
         {
           "name": "", #电影名称
           "url": "", #电影链接
           "url_profile_image": "", #封面图片url
           "publish_time": "" #上映时间
         }
       ],
       #音乐
       "music": [
         {
           "name": "", #音乐名称
           "url": "", #音乐链接
           "url_profile_image": "", #封面图片url
           "type": "" #类别名称
         }
       ],
       #视频
       "videos": [
         {
           "name": "", #视频名称
           "url": "", #视频链接
           "url_profile_image": "", #封面图片url
           "length": "" #视频时长
         }
       ],
       #书籍
       "book": [
         {
           "created_time": nil,
           "created_t": nil,
           "category": nil,
           "id": nil,
           "head_url": nil,
           "name": nil
         }
       ],
       #游戏
       "game": [
         {
           "created_time": nil,
           "created_t": nil,
           "category": nil,
           "id": nil,
           "head_url": nil,
           "name": nil
         }
       ],
       #游戏得分
       "game_score": [
         {
           "application": {
             "category": nil, #string 类别
             "namespace": nil, #string 游戏子类
             "link": nil, #string游戏链接
             "name": nil, #游戏名
             "id": nil, #id 游戏id
             "head_url": nil,
           },
           "score": nil, #int 得分
           "user": {
             "name": nil,
             "id": nil
           }
         }
       ]
     }
    }
  end



  def self.get_tag
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

  def self.facebook_user_size
    2000
  end
end
