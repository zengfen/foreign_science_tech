class ArchonTwitterTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class_name: "ArchonTwitter"
end
