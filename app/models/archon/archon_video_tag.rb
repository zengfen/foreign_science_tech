class ArchonVideoTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class: "ArchonVideo"
end
