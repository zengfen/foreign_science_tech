class ArchonFacebookComment < ArchonBase
  belongs_to :user, foreign_key: :user_id, class_name: "ArchonFacebookUser"

  def self.get_facebook_post_reply(oids)
    facebook_postReply = []
    self.where(post_oid:oids).limit(20).each do |x|
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
end
