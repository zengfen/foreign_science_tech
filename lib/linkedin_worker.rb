class LinkedinWorker
  def self.start
    while running?
      do_work

      sleep 5
    end
  end

  def self.do_work
    check_cookies

    stopped_ids, _, finished_ids = list_spider_tasks
    update_finished_tasks(finished_ids)

    return unless stopped_ids.blank?

    return if spider_task_count > 10


    ids = get_batch_users
    return if ids.blank?


    ids.each_slice(1000).each do |temp_ids|
      check_cookies
      return unless has_valid_account?
      create_tasks(temp_ids)
      set_users_dumped(temp_ids)
    end

  end

  def self.running?
    $archon_redis.get('archon_center_LinkedinWorker') == 'true'
  end

  def self.set_stop
    $archon_redis.set('archon_center_LinkedinWorker', 'false')
  end

  def self.set_start
    $archon_redis.set('archon_center_LinkedinWorker', 'true')
  end

  def self.has_valid_account?
    account = ControlTemplate.find(66).accounts.first
    return false if account.blank?

    account.is_valid?
  end

  def self.get_batch_users
    names = ArchonLinkedinName.where("has_skills = ?",false).select("id").limit(10000)
    ids = names.map{|x| x.id}
    return ids
  end

  def self.list_spider_tasks
    stopped_ids = SpiderTask.where(spider_id: 128, status: 3).collect(&:id)
    running_ids = SpiderTask.where(spider_id: 128, status: 1).collect(&:id)
    finished_ids = SpiderTask.where(spider_id: 128, status: 2).collect(&:id)

    [stopped_ids, running_ids, finished_ids]
  end

  def self.spider_task_count
    SpiderTask.where(spider_id: 128).count
  end

  def self.check_cookies
    ids = SpiderTask.where(spider_id: 128, status: 1).collect(&:id)
    return if ids.blank?

    subtask = DispatcherSubtaskStatus.where(task_id: ids, status: 3, error_content: 'cookie is expired').order('created_at desc').first
    if !subtask.blank? && subtask.created_at > 1.minute.ago.to_i
      account = ControlTemplate.find(66).accounts.first
      unless account.blank?
        account.valid_time = 5.minute.ago
        account.save
        account.remove_related_data
      end

      SpiderTask.where(spider_id: 128, status: 1).each(&:stop!)
    end
  end

  def self.create_tasks(ids)
    return if ids.blank?

    spider_task = SpiderTask.new(
      spider_id: 128,
      level: 1,
      max_retry_count: 0,
      keyword: ids.join(','),
      special_tag: '',
      status: 0,
      task_type: 2,
      is_split: false
    )
    spider_task.special_tag_transfor_id
    spider_task.save_with_spilt_keywords
    spider_task.start!
  end

  def self.set_users_dumped(ids)
    return if ids.blank?
    ArchonLinkedinName.where(id: ids).update_all(has_skills: true)
  end

  def self.set_users_finished(ids)
    return if ids.blank?
    ArchonLinkedinName.where(id: ids).update_all(is_finished: true)
  end

  def self.set_users_not_dumped(ids)
    return if ids.blank?
    ArchonLinkedinName.where(id: ids).update_all(has_skills: false)
  end

  def self.set_users_invalid(ids)
    return if ids.blank?
    ArchonLinkedinName.where(id: ids).update_all(is_finished: true, has_skills: true, is_invalid: true, is_dump: true)
  end

  def self.update_finished_tasks(ids)
    return if ids.blank?
    ids.each do |id|
      tasks = DispatcherSubtaskStatus.select('id, status, error_content').where(task_id: id)
      details = DispatcherSubtask.select("id, content").where(id: tasks.collect(&:id)).collect{|x| [x.id, JSON.parse(x.content)['url']]}.to_h
      finished_ids = []
      retry_ids = []
      invalid_ids = []
      tasks.each do |task|
        uid = details[task.id]
        if task.status == 3
          if task.error_content == "This profile can't be accessed" || task.error_content == "screenName is wrong" || task.error_content == "screenName is too lang"
            invalid_ids << uid unless uid.blank?
          else
            retry_ids << uid unless uid.blank?
          end
        else
          finished_ids << uid unless uid.blank?
        end
      end

      # set_users_finished(finished_ids) unless finished_ids.blank?

      set_users_not_dumped(retry_ids) unless retry_ids.blank?

      set_users_invalid(invalid_ids) unless invalid_ids.blank?

      SpiderTask.find(id).destroy
    end
  end
end
