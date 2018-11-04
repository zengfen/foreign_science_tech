class LinkedinSkillUser
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




    spider_task = SpiderTask.new(
      spider_id: 139,
      level: 1,
      max_retry_count: 0,
      keyword: data.join(','),
      special_tag: '',
      status: 0,
      timeout_second: 10,
      task_type: 2,
      is_split: false
    )
    spider_task.special_tag_transfor_id
    spider_task.save_with_spilt_keywords
    # spider_task.start!

  end
end
