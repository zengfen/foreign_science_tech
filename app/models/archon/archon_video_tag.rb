class ArchonVideoTag < ArchonBase

  belongs_to :archon_video, foreign_key: :pid
end
