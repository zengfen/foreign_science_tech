class ArchonLinkedinUserTag < ArchonBase
  belongs_to :archon_linkedin_user , foreign_key: :pid
end
