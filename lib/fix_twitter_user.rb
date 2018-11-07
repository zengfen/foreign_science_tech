class FixTwitterUser
  def self.fix_user
    ids = ArchonTwitterUser.select("id").where("updated_ts < 1539964800 and description = ''").limit(1000).collect(&:id)
    File.open("ArchonTwitterUser.txt", "a+") do |f|
      ids.each do |x|
        file.puts x
      end
    end

    new_ids = ids.each_slice(100).to_a.collect{|x| x.join("|")}.join(",")

    spider_task = SpiderTask.new(
      spider_id: 100,
      level: 1,
      max_retry_count: 0,
      keyword: new_ids,
      special_tag: '',
      status: 0,
      timeout_second: 10,
      task_type: 2,
      is_split: false,
      additional_function: [{"by_screen_name"=>"0"}, {"has_friends"=>"0"}],
    )
    spider_task.special_tag_transfor_id
    spider_task.save_with_spilt_keywords
  end
end
