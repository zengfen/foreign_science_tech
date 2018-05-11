class ArchonFacebookPostTag < ArchonBase
  belongs_to :record,  foreign_key: :pid, class: "ArchonFacebookPost"
end
