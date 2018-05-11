class ArchonFacebookCommentTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class_name: "ArchonFacebookComment"
end
