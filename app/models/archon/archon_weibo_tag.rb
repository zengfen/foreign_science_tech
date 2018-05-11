class ArchonWeiboTag < ArchonBase
  belongs_to :archon_weibo, foreign_key: :pid
end
