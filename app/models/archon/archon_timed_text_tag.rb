class ArchonTimedTextTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class_name: "ArchonTimedText"
end
