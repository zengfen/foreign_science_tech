class LinkedinSkillWorker
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

    return if spider_task_count > 15


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
    names = ArchonLinkedinName.where("is_skill_user = ? and is_finished = ?", false,true).select("id").limit(20000)
    ids = names.map{|x| x.id}
    return ids
  end

  def self.list_spider_tasks
    stopped_ids = SpiderTask.where(spider_id: 133, status: 3).collect(&:id)
    running_ids = SpiderTask.where(spider_id: 133, status: 1).collect(&:id)
    finished_ids = SpiderTask.where(spider_id: 133, status: 2).collect(&:id)

    [stopped_ids, running_ids, finished_ids]
  end

  def self.spider_task_count
    SpiderTask.where(spider_id: 133).count
  end

  def self.check_cookies
    ids = SpiderTask.where(spider_id: 133, status: 1).collect(&:id)
    return if ids.blank?

    subtask = DispatcherSubtaskStatus.where(task_id: ids, status: 3, error_content: 'cookie is expired').order('created_at desc').first
    if !subtask.blank? && subtask.created_at > 1.minute.ago.to_i
      account = ControlTemplate.find(66).accounts.first
      unless account.blank?
        account.valid_time = 5.minute.ago
        account.save
        account.remove_related_data
      end

      SpiderTask.where(spider_id: 133, status: 1).each(&:stop!)
    end
  end

  def self.create_tasks(ids)
    return if ids.blank?

    users = ArchonLinkedinUser.select("id, skills").where(id: ids)
    return if users.blank?

    reset_skill_uids = []

    data = []

    final_data = []

    users.each do |user|
      skill = user.skills
      next if skill.blank?

      skill = JSON.parse(skill) rescue nil
      if skill.blank?
        reset_skill_uids << user.id
        next
      end

      skill_values = skill.values
      skill_values.delete(nil)
      skill_values.delete("")
      skill_values.flatten!
      next if skill_values.blank?

      first_skill = skill_values.first
      if first_skill["skillId"].blank?
        reset_skill_uids << user.id
        next
      end


      skill_values.each do |skill_value|
        next if skill_value["endorsementCount"].to_i < 20
        sid =  skill_value["skillId"].split("fs_skill:(").last.gsub(")", "").split(",")
        data << "#{sid[0]}|#{sid[1]}"
      end

    end

    group_count = data.length / 5

    group_count = 1 if group_count == 0

    data.in_groups(group_count, false).each do |x|
      final_data << "#{x.join('|||')}"
    end


    reset_users_has_skill(reset_skill_uids)

    spider_task = SpiderTask.new(
      spider_id: 133,
      level: 1,
      max_retry_count: 0,
      keyword: final_data.join(','),
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
    ArchonLinkedinName.where(id: ids).update_all(is_skill_user: true)
  end

  def self.set_users_not_dumped(ids)
    return if ids.blank?
    ArchonLinkedinName.where(id: ids).update_all(is_skill_user: false)
  end


  def self.reset_users_has_skill(ids)
    return if ids.blank?
    ArchonLinkedinName.where(id: ids).update_all(has_skills: false)
  end


  def self.update_finished_tasks(ids)
    return if ids.blank?
    ids.each do |id|

      task = SpiderTask.find(id) rescue nil
      next if task.blank?
      if task.current_fail_count == 0
        task.destroy
      else
        task.retry_all_fail_task
      end

    end
  end

end
