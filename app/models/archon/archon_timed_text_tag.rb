class ArchonTimedTextTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class: "ArchonTimedText"
end
