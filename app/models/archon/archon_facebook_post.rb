class ArchonFacebookPost < ArchonBase
  belongs_to :user, foreign_key: :user_id, class_name: "ArchonFacebookUser"
end
