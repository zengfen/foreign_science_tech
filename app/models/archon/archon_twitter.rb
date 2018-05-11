class ArchonTwitter < ArchonBase
  belongs_to :user, foreign_key: :user_id, class: "ArchonTwitterUser"
  belongs_to :retweet_user, foreign_key: :retweet_user_id, class: "ArchonTwitterUser"
end
