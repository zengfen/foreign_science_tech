class ArchonNewsTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class_name: "ArchonNews"
end
