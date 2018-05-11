class ArchonFacebookPostTag < ArchonBase
  belongs_to :archon_facebook_post , foreign_key: :pid
end
