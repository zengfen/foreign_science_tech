class LinkedinSkillUser
  def self.check
    while true
      do_work

      puts "11"
      sleep 5
    end
  end


  def self.check_cookies
    ids = SpiderTask.where(spider_id: 139, status: 1).collect(&:id)
    return if ids.blank?

    subtask = DispatcherSubtaskStatus.where(task_id: ids, status: 3, error_content: 'cookie is expired').order('created_at desc').first
    if !subtask.blank? && subtask.created_at > 1.minute.ago.to_i
      account = ControlTemplate.find(75).accounts.first
      unless account.blank?
        account.valid_time = 5.minute.ago
        account.save
        account.remove_related_data
      end

      SpiderTask.where(spider_id: 139, status: 1).each(&:stop!)
    end
  end


  def self.create_tasks(ids)
    return if ids.blank?

    users = ArchonLinkedinUser.select("id, skills").where(id: ids)
    return if users.blank?


    data = []

    users.each do |user|
      skill = user.skills
      next if skill.blank?

      skill = JSON.parse(skill) rescue nil
      if skill.blank?
        next
      end

      skill_values = skill.values
      skill_values.delete(nil)
      skill_values.delete("")
      skill_values.flatten!
      next if skill_values.blank?

      skill_values.each do |skill_value|
        next if skill_value["endorsementCount"].to_i == 0
        sid =  skill_value["skillId"].split("fs_skill:(").last.gsub(")", "").split(",")
        data << "#{user.id}|#{sid[0]}|#{sid[1]}"
      end

    end



    data.uniq.each_slice(500).each do |new_data|
      spider_task = SpiderTask.new(
        spider_id: 139,
        level: 1,
        max_retry_count: 0,
        keyword: new_data.join(','),
        special_tag: '',
        status: 0,
        timeout_second: 10,
        task_type: 2,
        is_split: false
      )
      spider_task.special_tag_transfor_id
      spider_task.save_with_spilt_keywords
    end


    # spider_task.start!

  end
end
