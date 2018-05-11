class ArchonVideoCommentTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class: "ArchonVideoComment"
end
