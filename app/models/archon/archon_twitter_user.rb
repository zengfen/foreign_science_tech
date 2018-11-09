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


  def self.check_create_tasks(file)
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


    new_ids.each_slice(3000).each do |temp_ids|
      spider_task = SpiderTask.new(
        spider_id: 100,
        level: 1,
        max_retry_count: 0,
        keyword: temp_ids.each_slice(100).to_a.collect { |x| x.join('|') }.join(','),
        special_tag: '',
        status: 0,
        timeout_second: 10,
        task_type: 2,
        is_split: false,
        additional_function: [{ 'by_screen_name' => '1' }, { 'has_friends' => '0' }]
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

    File.open(out) do |f|
      new_ids.each do |x|
        f.puts x
      end
    end

    out
  end
end
