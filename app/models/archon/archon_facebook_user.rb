class ArchonFacebookUser < ArchonBase
  def self.check_create_tasks(file)
    ids = []

    File.new(file).each do |x|
      next if x.blank?

      ids << x.strip.downcase
    end

    ids.uniq!

    ids.each_slice(3000).each do |temp_ids|
      spider_task = SpiderTask.new(
        spider_id: 141,
        level: 1,
        max_retry_count: 0,
        keyword: temp_ids.join(','),
        special_tag: '',
        status: 0,
        timeout_second: 15,
        task_type: 2,
        is_split: false,
      )
      spider_task.special_tag_transfor_id
      spider_task.save_with_spilt_keywords
      spider_task.start!
    end
  end


  def self.dump_not_exist_user(file)
    ids = []

    File.new(file).each do |x|
      next if x.blank?

      ids << x.strip.downcase
    end

    ids.uniq!


    new_ids = []
    ids.each_slice(3000).each do |temp_ids|
      names = ArchonTwitterUser.select("screen_name_lower").where(screen_name_lower: temp_ids).collect(&:screen_name_lower)

      new_ids += (temp_ids - names)
    end


    out = "dump_#{Time.now.to_i}"

    File.open(out, "w") do |f|
      new_ids.each do |x|
        f.puts x
      end
    end

    out
  end

end
