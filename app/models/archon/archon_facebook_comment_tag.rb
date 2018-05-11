class ArchonFacebookCommentTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class: "ArchonFacebookComment"
end
