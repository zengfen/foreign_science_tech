class ArchonTwitterUser < ArchonBase
  def self.fix_screen_name
    start_id = 0
    end_id = 0


    while true
      ids = ArchonTwitterUser.select("id").where("id > #{start_id}").order("id asc").limit(20000).collect(&:id)
      break if ids.blank?

      start_id = ids.first
      puts start_id
      end_id = ids.last
      puts end_id

      ArchonTwitterUser.where("id >= #{start_id} and id <=#{end_id}").update_all("screen_name_lower = lower(screen_name)")


      start_id = end_id
    end
  end
end
