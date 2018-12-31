class ArchonTwitterUser < ArchonBase
  def self.fix_screen_name
    start_id = 0
    end_id = 0


    while true
      ids = ArchonTwitterUser.select("id").where("id > #{start_id}").order("id asc").limit(20000).collect(&:id)
      break if ids.blank?

      start_id = ids.first
      puts start_id
      end_id = ids.last
      puts end_id

      ArchonTwitterUser.where("id >= #{start_id} and id <=#{end_id}").update_all("screen_name_lower = lower(screen_name)")


      start_id = end_id
    end
  end


  def self.check_create_tasks(file)
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


    new_ids.each_slice(3000).each do |temp_ids|
      spider_task = SpiderTask.new(
        spider_id: 100,
        level: 1,
        max_retry_count: 0,
        keyword: temp_ids.each_slice(100).to_a.collect { |x| x.join('|') }.join(','),
        special_tag: '',
        status: 0,
        timeout_second: 10,
        task_type: 2,
        is_split: false,
        additional_function: [{'by_screen_name' => '1'}, {'has_friends' => '0'}]
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
    "CynthiaAGriffin,TerryBranstad,johnsonrc01,mattmurray8,PetersFrancisM,jiminjava,clarkledger,KeithLommel,cannonsmith,ngraytishman,sean_stein,Boolbada,daphelps,Hokaheyhockey,Carlahitch,paradisoDX,tongkurt,tahinman".split(",")
  end


  # nohup rails r ArchonTwitterUser.dump_data_to_json &
  def self.dump_data_to_json
    tag = get_tag
    datas = []
    unknow_hash = self.unknow_hash
    count = 0

    # file_path = "dump_1123123.txt"
    file_path = "#{Rails.root}/public/json_datas/dump_20_56.txt"
    user_id_datas = []
    File.open(file_path, "r") do |f|
      while data  = f.gets
        user_id_datas << JSON.parse(data)
      end
    end
    user_ids = user_id_datas.map{|x| x["userid"]}
    # ArchonTwitterUser.where(id: user_ids).find_each do |user|
    ArchonTwitterUser.where(screen_name: user_ids).find_each do |user|
      ids_data = user_id_datas.find{|x| x["userid"] == user.id}
      post_ids = ids_data["post_ids"]
      reply_ids = ids_data["reply_ids"]
      retweet_ids = ids_data["retweet_ids"]

      basic = user.get_twitter_basic
      post = ArchonTwitter.get_twitter_post_datas(post_ids, user.id, user.name, user.screen_name)
      postReply = ArchonTwitter.get_twittwer_post_reply_datas(reply_ids)
      postForward = ArchonTwitter.get_twittwer_post_forward_datas(retweet_ids)
      follower = ArchonTwitterFriend.get_twittwer_followers(user.id)
      data = {twittwer: {}}
      twittwer = {}
      twittwer["basic"] = basic
      twittwer["post"] = post
      twittwer["postReply"] = postReply
      twittwer["postForward"] = postForward
      twittwer["follower"] = follower
      data[:twittwer] = twittwer.merge(unknow_hash)
      # datas << data.to_json
      $redis.sadd("archon_center_twitter_datas", data.to_json)


      # basic = user.get_twitter_basic
      # post = ArchonTwitter.get_twitter_post(user.id, user.name, user.screen_name, tag)
      # next if post.blank?
      # oids = post.map{|x| x[:tweetID] }
      # postReply = ArchonTwitter.get_twittwer_post_reply(oids)
      # postForward = ArchonTwitter.get_twittwer_post_forward(oids)
      # follower = ArchonTwitterFriend.get_twittwer_followers(user.id)
      # count += 1
      # break if count > twitter_user_size
      # data = {twittwer: {}}
      # twittwer = {}
      # twittwer["basic"] = basic
      # twittwer["post"] = post
      # twittwer["postReply"] = postReply
      # twittwer["postForward"] = postForward
      # twittwer["follower"] = follower
      # data[:twittwer] = twittwer.merge(unknow_hash)
      # # datas << data.to_json
      # $redis.sadd("archon_center_twitter_datas", data.to_json)
    end

  end

  # nohup rails r ArchonTwitterUser.read_redis_to_file &
  def self.read_redis_to_file
    while true
      datas = []
      200.times do
        data = $redis.spop("archon_center_twitter_datas")
        break if data.blank?
        datas << data
      end
      break if datas.blank?
      File.open("#{json_file_path}/twitter_data.json", "a+") {|f| f.puts datas}
    end
  end

  def get_twitter_basic
    twitter_basic = {
      "userId": self.id, #int
      "userName": self.name, #string    名称
      "userScreenName": self.screen_name, #string    用户昵称
      "headUrl": self.profile_image_url, #string    头像
      "bkgdUrl": nil, #string    背景图片
      "website": "https://twitter.com/#{self.screen_name}", #string    个人twitter页面地址
      "description": self.description, #string    简介
      "location": self.location, #string                    #位置
      "createdAt": (Time.at(self.created_at).strftime("%Y%m%d%H%M%S") rescue nil), #string  #加入时间
      "birthday": "", #string 出生日期
      "timelineCount": self.status_count, #int       推文数目
      "friendCount": self.friend_count, #int       关注的人数目
      "followerCount": self.follower_count, #int       被关注的人数目
      "likeCount": self.favourite_count, #int       点赞的推文数目
      "phone": "", #电话      （预留）
      "userEmail": self.email #用户邮箱  （预留）
    }
  end

  def self.unknow_hash
    {
      #被关注人列表  暂时没有
      "followedBy": [#主userId见basic部分
        {
          "userId": "", #Followed ID，即当前操作者ID（用于标定follower和操作者的关系）
          "userName": "", #Followed Name，即当前操作者名称
          "userScreen": "", #Followed Screen Name，即当前操作者昵称
          "userPhoto": "", #Follower头像
        }
      ],
      #其他信息
      "others": []
    }
  end

  def self.get_tag
    252
  end

  # 存储
  def self.tag_post_ids(tag = 252)
    ArchonTwitterTag.where(tag: tag).find_each do |x|
      $redis.sadd("archon_center_#{tag}_twitter_post_ids", x.pid)
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


  def self.twitter_user_size
    2000
  end

end
