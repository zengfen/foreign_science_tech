class ArchonNewsTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class: "ArchonNews"
end
