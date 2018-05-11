class ArchonTwitterTag < ArchonBase
  belongs_to :archon_twitter, foreign_key: :pid
end
