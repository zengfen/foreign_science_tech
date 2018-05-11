class ArchonVideoCommentTag < ArchonBase
  belongs_to :archon_video_comment, foreign_key: :pid
end
