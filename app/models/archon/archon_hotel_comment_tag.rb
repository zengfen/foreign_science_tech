class ArchonHotelCommentTag < ArchonBase
  belongs_to :record , foreign_key: :pid, class_name: "ArchonHotelComment"
end
