class ArchonLinkedinUserTag < ArchonBase
  belongs_to :archon_linkedin_users , foreign_key: :pid
end
