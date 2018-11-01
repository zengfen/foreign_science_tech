class ArchonTwitter < ArchonBase
  belongs_to :user, foreign_key: :user_id, class_name: "ArchonTwitterUser"
  belongs_to :retweet_user, foreign_key: :retweet_user_id, class_name: "ArchonTwitterUser"


  def self.dump_twitter_ids
    user_id = []
    ArchonTwitter.select("id,user_id").where("place != ''").each do |x|
      user_id << x.user_id
      $redis.sadd("dump_twitter_ids_for_fix", x.id)
    end


    puts user_id.uniq.size

    nil
  end
end
