class ArchonPictureCommentTag < ArchonBase
  belongs_to :archon_picture_comment, foreign_key: :pid
end
