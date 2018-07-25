class ArchonScenicCommentTag < ArchonBase
  belongs_to :record , foreign_key: :pid, class_name: "ArchonScenicComment"
end
