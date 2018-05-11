class ArchonWeiboTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class_name: "ArchonWeibo"
end
