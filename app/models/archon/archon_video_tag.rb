class ArchonVideoTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class_name: "ArchonVideo"
end
