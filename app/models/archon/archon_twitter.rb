class ArchonTwitter < ArchonBase
  belongs_to :user, foreign_key: :user_id, class_name: "ArchonTwitterUser"
  belongs_to :retweet_user, foreign_key: :retweet_user_id, class_name: "ArchonTwitterUser"


  def self.dump_text
    offset_id = 0
    tag = 244
    while true
      res = ArchonTwitterTag.where("id > #{offset_id} and tag = #{tag}").order("id asc").limit(20000)
      ids = res.collect{|x| x.pid}
      break if ids.blank?
      puts offset_id = res.last.id
      ArchonTwitter.select("id,title").where(id:ids).each do |tw|
        File.open("244_twitter_text.txt","a"){|f| f.puts tw.title.to_s.gsub("\n","")}
      end
    end
  end

  def self.dump_twitter_ids
    ids = $redis.smembers("dump_twitter_ids_for_fix")

    tags = ArchonTwitterTag.where(pid: ids)
    tags.each do |t|
      next if t.tag != 232 && t.tag != 233
      $redis.sadd("twitter_by_tag_#{t.tag}", t.pid)
      $redis.sadd("twitter_tag_ids", t.id)
    end
    # user_id = []
    # ArchonTwitter.select("id,user_id").where("place != ''").each do |x|
    #   user_id << x.user_id
    #   $redis.sadd("dump_twitter_ids_for_fix", x.id)
    # end


    # puts user_id.uniq.size

    nil
  end


  def self.delete_twitter_ids
    ids = $redis.smembers("twitter_by_tag_232")
    ids.each_slice(1000).each do |new_ids|
      spider_task = SpiderTask.new(
        spider_id: 92,
        level: 1,
        max_retry_count: 0,
        keyword: new_ids.each_slice(100).to_a.collect{|x| x.join("|")}.join(","),
        timeout_second: 15,
        special_tag: 'tjwwj',
        status: 0,
        task_type: 2,
        is_split: false
      )
      spider_task.special_tag_transfor_id
      spider_task.save_with_spilt_keywords
      spider_task.start!
    end


    ids = $redis.smembers("twitter_by_tag_233")
    ids.each_slice(1000).each do |new_ids|
      spider_task = SpiderTask.new(
        spider_id: 92,
        level: 1,
        max_retry_count: 0,
        keyword: new_ids.each_slice(100).to_a.collect{|x| x.join("|")}.join(","),
        timeout_second: 15,
        special_tag: 'tjwwj9',
        status: 0,
        task_type: 2,
        is_split: false
      )
      spider_task.special_tag_transfor_id
      spider_task.save_with_spilt_keywords
      spider_task.start!
    end


    # ids = $redis.smembers("twitter_tag_ids")
    # ids.each_slice(10000).each do |new_ids|
    #   ArchonTwitterTag.where(id: new_ids).delete_all
    # end





    # ids = $redis.smembers("twitter_by_tag_233")
    # ids.each_slice(10000).each do |new_ids|
    #   ArchonTwitter.where(id: new_ids).delete_all
    # end


    # ids = $redis.smembers("twitter_by_tag_233")
    # ids.each_slice(10000).each do |new_ids|
    #   ArchonTwitter.where(id: new_ids).delete_all
    # end
    nil
  end


  def self.get_twitter_post(user_id, tag)

    ArchonTwitter.where(user_id: 608852718).limit(10).each do |x|

    end


    twitter_post = []
    count = 0
    self.where(user_id: user_id).find_each do |x|
      # 若这条post的tag不为指定tag 则取下一条数据
      next if !$redis.sismember("archon_center_#{tag}_twitter_post_ids", x.id)
      count += 1
      # 只取10条数据
      break if count > 10
      twitter_post << twitter_post << {
        "tweetID": x.id, #推文ID （唯一标定推文）
        "userId": x.user_id, #int 发帖人ID
        "userName": user.name, #string    发帖人名称
        "userScreenName": user.screen_name, #string    发帖人昵称
        "content": x.title, #推文内容
        "mediaUrl": (JSON.parse(x.images) rescue []) + (JSON.parse(x.videos) rescue []), #视频或图片的URL
        "location": {#经纬度和地址
                     "latitude": nil,
                     "longitude": nil,
                     "address": ""
        }, #地理位置
        "pubTme": (x.created_time.strftime("%Y%m%d%H%M%S") rescue null), #发布时间
        "mentionID": [
          {
            "userId": 4555613712, #int 发帖人ID
            "userName": "John Berming", #string    发帖人名称
          }
        ], #MENTIONS列表
        "visitUrl": x.source_url, #原文信息URL
      }
    end
    return twitter_post
  end

  def self.get_twittwer_post_reply(oids)
    postReply = []
    self.where(in_reply_to_status_id: oids).limit(20).each do |x|
      postReply << {
        "tweetId": x.in_reply_to_status_id, #被回复主推文ID（唯一标定推文）
        "parentId": "", #被回复ID，用于回复的回复。
        "replyId": x.id, #回复ID
        "replyContent": x.title, #回复内容
        "mediaUrl": (JSON.parse(x.images) rescue []) + (JSON.parse(x.videos) rescue []),  #视频或图片的URL
        "replyTime": (x.created_time.strftime("%Y%m%d%H%M%S") rescue null), #回复时间
        "userId": x.in_reply_to_user_id, #回复者ID（用于标定推文与发布者的关系）
        "userName": "", #回复者名称
        "userScreenName": x.in_reply_to_screen_name,
        "mentionId": [
          {
            "userId": nil, #int 发帖人ID
            "userName": nil, #string    发帖人名称
          }
        ], #MENTIONS列表
      }
    end
    return postReply
  end

  def self.get_twittwer_post_forward(oids)
    postForward = []
    self.where(in_reply_to_status_id: oids).limit(20).each do |x|
      postForward << {
        "tweetId": x.retweeted_status_id, #被转发推文ID （唯一标定推文）
        "forwardContent": x.retweeted_status_text, #转发内容
        "mediaUrl": (JSON.parse(x.images) rescue []) + (JSON.parse(x.videos) rescue []), #视频或图片的URL
        "userId": x.retweet_user_id, #转发者ID（用于标定推文与发布者的关系）
        "userName": "", #转发者名称
        "userScreen": "", #转发者昵称
        "forwardTime": (x.retweeted_status_created_at.strftime("%Y%m%d%H%M%S") rescue null), #转发时间
        "mentionId": [
          {
            "userId": nil, #int 发帖人ID
            "userName": nil, #string    发帖人名称
          }
        ], #MENTIONS列表
      }
    end
    user_ids = postForward.map{|x| x[:userId]}.compact - ['']
    users = ArchonTwitterUser.find(user_ids).map{|x| {userId: x.id, userName: x.name, userScreen: x.screen_name}}
    postForward.each do |x|
      user_info = users.find{|x| x[:userId] == x[:userId]}
      next if user_info.blank?
      x.merge!(user_info)
    end
    return postForward
  end


end
