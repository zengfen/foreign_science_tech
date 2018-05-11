class ArchonPictureTag < ArchonBase

  belongs_to :archon_picture, foreign_key: :pid
end
