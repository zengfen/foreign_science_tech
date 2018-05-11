class ArchonFacebookComment < ArchonBase
  belongs_to :user, foreign_key: :user_id, class: "ArchonFacebookUser"
end
