class ArchonTwitterTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class: "ArchonTwitter"
end
