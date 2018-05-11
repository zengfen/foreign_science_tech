class ArchonTimedTextTag < ArchonBase
  belongs_to :archon_timed_text, foreign_key: :pid
end
