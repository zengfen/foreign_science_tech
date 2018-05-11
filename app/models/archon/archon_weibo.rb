class ArchonWeibo < ArchonBase
  belongs_to :user, foreign_key: :user_id , class: "ArchonWeiboUser"
  belongs_to :retweet_user, foreign_key: :retweet_user_id, class: "ArchonWeiboUser"
end
