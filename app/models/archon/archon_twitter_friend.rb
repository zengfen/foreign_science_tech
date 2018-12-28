class ArchonTwitterFriend < ArchonBase

  def self.get_twittwer_followers(user_id)
    follower = []
    friend_ids = ArchonTwitterFriend.find(id: user_id).friend_ids.split(",")
    ArchonTwitterUser.find(friend_ids).each do |x|
      follower << {
        "userId": x.id, #Follower ID，即当前操作者ID（用于标定followeing和操作者的关系）
        "userName": x.name, #Follower Name，即当前操作者名称
        "userScreen": x.screen_name, #Follower Screen Name，即当前操作者昵称
        "userPhoto": "", #Following 头像
      }
    end
    return follower
  end
end
