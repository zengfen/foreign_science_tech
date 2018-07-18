class ArchonPlaceTag  < ArchonBase
  belongs_to :record , foreign_key: :pid, class_name: "ArchonPlace"
end
