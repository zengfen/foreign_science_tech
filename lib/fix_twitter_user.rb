class FixTwitterUser
  def self.fix_user
    ids = ArchonTwitterUser.select('id').where("updated_ts < 1539964800 and description = ''").limit(30_000).collect(&:id)
    File.open('ArchonTwitterUser.txt', 'a+') do |f|
      ids.each do |x|
        f.puts x
      end
    end

    ids.each_slice(3000).each do |temp_ids|
      new_ids = temp_ids.each_slice(100).to_a.collect { |x| x.join('|') }.join(',')

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
        additional_function: [{ 'by_screen_name' => '0' }, { 'has_friends' => '0' }]
      )
      spider_task.special_tag_transfor_id
      spider_task.save_with_spilt_keywords
      spider_task.start


      ArchonTwitterUser.where(id: temp_ids).delete_all
    end
  end
end
