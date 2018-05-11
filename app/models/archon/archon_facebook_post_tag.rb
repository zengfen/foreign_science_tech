class ArchonFacebookPostTag < ArchonBase
  has_one :archon_facebook_post , foreign_key: :pid
end
