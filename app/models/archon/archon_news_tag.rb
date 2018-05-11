class ArchonNewsTag < ArchonBase
  belongs_to :archon_news, foreign_key: :pid
end
