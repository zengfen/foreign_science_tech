class ArchonLinkedinUserTag < ArchonBase
  belongs_to :record , foreign_key: :pid, class_name: "ArchonLinkedinUser"
end
