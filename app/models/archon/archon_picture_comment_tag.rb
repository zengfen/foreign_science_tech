class ArchonPictureCommentTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class_name: "ArchonPictureComment"
end
