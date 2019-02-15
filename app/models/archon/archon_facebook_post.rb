class ArchonFacebookPost < ArchonBase
  belongs_to :user, foreign_key: :user_id, class_name: "ArchonFacebookUser"
  def self.dump_text
    offset_id = 0
    tag = 244
    while true
      res = ArchonFacebookPostTag.where("id > #{offset_id} and tag = #{tag}").order("id asc").limit(20000)
      ids = res.collect{|x| x.pid}
      break if ids.blank?
      puts offset_id = res.last.id
      ArchonFacebookPost.select("id,title").where(id:ids).each do |tw|
        File.open("244_facebook_text.txt","a"){|f| f.puts tw.title.to_s.gsub("\n","")}
      end
    end
  end


  def self.get_facebook_post(post_ids)
    facebook_post = []
    self.where(id:post_ids).each do |x|
      facebook_post << {
        #发布者信息
        "userId": x.user_id, #分享者ID（用来进行关联）
        "userScreenName": x.user_screen_name, #分享者昵称
        "userName": x.user_name, #分享者名称
        #文章信息
        "shareId": x.oid, #分享ID（用来进行分享与用户关联）
        "shareContent": x.title, #分享内容
        "mediaUrl": (JSON.parse(x.images) rescue []) + (JSON.parse(x.videos) rescue []) + (JSON.parse(x.links) rescue []), #分享的照片/视频URL
        "mentionUsers": [#文章中提及到的Facebook用户
          {
            "userId": "", # int facebook用户ID
            "userName": "", #string 姓名"
          }
        ],
        "shareTime": (Time.at(x.created_time).strftime("%Y%m%d%H%M%S") rescue nil), #分享时间
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
        "publishTime": (Time.at(x.created_time).strftime("%Y%m%d%H%M%S") rescue nil), #发布时间，格式：yyyyMMddHHmmss
        "updatedTime": (Time.at(x.updated_at).strftime("%Y%m%d%H%M%S") rescue nil), #更新时间，格式：yyyyMMddHHmmss
        "tags": nil #文章的标签
      }
    end
    return facebook_post
  end


  # 获取部分有post数据的fb人物
  def self.temp_dump_facebook_users
    ids0 = ArchonFacebookPost.select("id,user_id").limit(100000).reorder('').collect{|x| [x.id, x.user_id]}

    ids00 = {}
    ids0.each do |x|
      ids00[x[1]] ||= []
      ids00[x[1]] << x[0]
    end

    ids1 = ArchonFacebookComment.select("id,user_id").where(user_id:ids00.keys).reorder('').collect{|x| [x.id, x.user_id]}
    ids11 = {}
    ids1.each do |x|
      ids11[x[1]] ||= []
      ids11[x[1]] << x[0]
    end

    ids2 = ids00.keys
    # & ids1.collect{|x| x[1]}

    exist_uids = ArchonFacebookUser.select("id").where(id: ids2).reorder(nil).collect(&:id)


    f = File.open("#{Rails.root}/public/json_datas/temp_facebook_users.txt", "w")

    exist_uids[0,1500].each do |x|
      line = {userid: x, post_ids: ids00[x][0..4], comment_ids: ids11[x].to_a[0..4]}
      f.puts line.to_json
    end

    f.close
  end



end
