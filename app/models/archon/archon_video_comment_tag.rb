class ArchonVideoCommentTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class_name: "ArchonVideoComment"
end
