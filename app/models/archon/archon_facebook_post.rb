class ArchonFacebookPost < ArchonBase
  belongs_to :user, foreign_key: :user_id, class_name: "ArchonFacebookUser"
  def self.dump_text
    offset_id = 0
    tag = 244
    while true
      res = ArchonFacebookPostTag.where("id > #{offset_id} and tag = #{tag}").order("id asc").limit(20000)
      ids = res.collect{|x| x.pid}
      break if ids.blank?
      puts offset_id = res.last.id
      ArchonFacebookPost.select("id,title").where(id:ids).each do |tw|
        File.open("244_facebook_text.txt","a"){|f| f.puts tw.title.to_s.gsub("\n","")}
      end
    end
  end
end
