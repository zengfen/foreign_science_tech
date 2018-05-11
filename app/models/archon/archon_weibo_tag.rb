class ArchonWeiboTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class: "ArchonWeibo"
end
