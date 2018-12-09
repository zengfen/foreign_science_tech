class ArchonTwitter < ArchonBase
  #belongs_to :user, foreign_key: :user_id, class_name: "ArchonTwitterUser"
  #belongs_to :retweet_user, foreign_key: :retweet_user_id, class_name: "ArchonTwitterUser"


  def self.dump_text
    offset_id = 0
    tag = 244
    while true
      res = ArchonTwitterTag.where("id > #{offset_id} and tag = #{tag}").order("id asc").limit(20000)
      ids = res.collect{|x| x.pid}
      break if ids.blank?
      puts offset_id = res.last.id
      ArchonTwitter.select("id,title").where(id:ids).each do |tw|
        File.open("244_twitter_text.txt","a"){|f| f.puts tw.title.to_s.gsub("\n","")}
      end
    end
  end

  def self.dump_twitter_ids
    ids = $redis.smembers("dump_twitter_ids_for_fix")

    tags = ArchonTwitterTag.where(pid: ids)
    tags.each do |t|
      next if t.tag != 232 && t.tag != 233
      $redis.sadd("twitter_by_tag_#{t.tag}", t.pid)
      $redis.sadd("twitter_tag_ids", t.id)
    end
    # user_id = []
    # ArchonTwitter.select("id,user_id").where("place != ''").each do |x|
    #   user_id << x.user_id
    #   $redis.sadd("dump_twitter_ids_for_fix", x.id)
    # end


    # puts user_id.uniq.size

    nil
  end


  def self.delete_twitter_ids
    ids = $redis.smembers("twitter_by_tag_232")
    ids.each_slice(1000).each do |new_ids|
      spider_task = SpiderTask.new(
        spider_id: 92,
        level: 1,
        max_retry_count: 0,
        keyword: new_ids.each_slice(100).to_a.collect{|x| x.join("|")}.join(","),
        timeout_second: 15,
        special_tag: 'tjwwj',
        status: 0,
        task_type: 2,
        is_split: false
      )
      spider_task.special_tag_transfor_id
      spider_task.save_with_spilt_keywords
      spider_task.start!
    end


    ids = $redis.smembers("twitter_by_tag_233")
    ids.each_slice(1000).each do |new_ids|
      spider_task = SpiderTask.new(
        spider_id: 92,
        level: 1,
        max_retry_count: 0,
        keyword: new_ids.each_slice(100).to_a.collect{|x| x.join("|")}.join(","),
        timeout_second: 15,
        special_tag: 'tjwwj9',
        status: 0,
        task_type: 2,
        is_split: false
      )
      spider_task.special_tag_transfor_id
      spider_task.save_with_spilt_keywords
      spider_task.start!
    end


    # ids = $redis.smembers("twitter_tag_ids")
    # ids.each_slice(10000).each do |new_ids|
    #   ArchonTwitterTag.where(id: new_ids).delete_all
    # end





    # ids = $redis.smembers("twitter_by_tag_233")
    # ids.each_slice(10000).each do |new_ids|
    #   ArchonTwitter.where(id: new_ids).delete_all
    # end


    # ids = $redis.smembers("twitter_by_tag_233")
    # ids.each_slice(10000).each do |new_ids|
    #   ArchonTwitter.where(id: new_ids).delete_all
    # end
    nil
  end
end
