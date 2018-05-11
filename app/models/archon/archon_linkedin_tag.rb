class ArchonLinkedinTag < ArchonBase
  belongs_to :record , foreign_key: :pid, class: "ArchonLinkedin"
end
