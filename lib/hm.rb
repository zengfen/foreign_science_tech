class Hm


  def self.work
    while true
      ids = SpiderTask.where(spider_id: 128, status: 1).collect(&:id)
      if ids.blank?
        sleep(10)
        next
      end

      subtask = DispatcherSubtaskStatus.where(task_id: ids, status: 3, error_content: "cookie is expired").order("created_at desc").first
      if  !subtask.blank? && subtask.created_at > 1.minute.ago.to_i
        account = ControlTemplate.find(66).accounts.first
        if !account.blank?
          account.valid_time = 5.minute.ago
          account.save
          account.remove_related_data
        end

        SpiderTask.where(spider_id: 128, status: 1).each do |x|
          x.stop!
        end
      end


      account = ControlTemplate.find(66).accounts.first
      if !account.blank? && account.is_valid?
        if AliyunHost.need_reopen
          account.remove_related_data

          sleep(15)
          AliyunHost.reopen
        end
      end

      sleep(10)
    end
  end

  def self.reopen
    return if !AliyunHost.need_reopen

    AliyunHost.close_all_hosts
    ips = AliyunHost.reopen_hosts(5)

    puts ips

    account = ControlTemplate.find(66).accounts.first
    if !account.blank?
      account.remove_related_data
      account.valid_ips = ips
      account.save
      account.setup_redis
    end
  end
end
