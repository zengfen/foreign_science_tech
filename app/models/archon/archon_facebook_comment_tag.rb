class ArchonFacebookCommentTag < ArchonBase
  belongs_to :archon_facebook_comment, foreign_key: :pid
end
