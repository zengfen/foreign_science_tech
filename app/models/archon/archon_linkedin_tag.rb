class ArchonLinkedinTag < ArchonBase
  belongs_to :archon_linkedin , foreign_key: :pid
end
