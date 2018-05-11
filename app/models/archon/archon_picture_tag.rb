class ArchonPictureTag < ArchonBase
  belongs_to :record, foreign_key: :pid, class: "ArchonPicture"
end
