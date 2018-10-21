class Hm
  def self.work
    loop do
      ids = SpiderTask.where(spider_id: 128, status: 1).collect(&:id)
      if ids.blank?
        sleep(10)
        next
      end

      subtask = DispatcherSubtaskStatus.where(task_id: ids, status: 3, error_content: 'cookie is expired').order('created_at desc').first
      if !subtask.blank? && subtask.created_at > 1.minute.ago.to_i
        account = ControlTemplate.find(70).accounts.first
        unless account.blank?
          account.valid_time = 5.minute.ago
          account.save
          account.remove_related_data
        end

        SpiderTask.where(spider_id: 128, status: 1).each(&:stop!)
      end

      # check_reopen

      sleep(10)
    end
  end

  def self.check_reopen(c  = 1)
    account = ControlTemplate.find(70).accounts.first
    if !account.blank? && account.is_valid?
      account.remove_related_data

      sleep(15)

      AliyunHost.close_all_hosts
      ips = AliyunHost.reopen_hosts(c)

      puts ips

      account.remove_related_data
      account.valid_ips = ips
      account.save
      account.setup_redis
    end
  end


  def self.reset_ips
    account = ControlTemplate.find(70).accounts.first
    if !account.blank? && account.is_valid?
      account.remove_related_data
      account.valid_ips = AliyunHost.get_all_ips
      account.save
      account.setup_redis
    end
  end



  def self.reset_accounts
    ArchonLinkedinUser.where("created_ts > 1538979587").select("id").collect(&:id).each_slice(1000).each do |ids|
      ArchonLinkedinUser.where(id: ids).delete_all
      LinkedinWorker.set_users_not_dumped(ids)
    end

    nil
  end


  def self.do_stop_all_agent
    start_ts = Time.now.to_i

    while (Time.now.to_i - 6 * 3600) < start_ts

      sleep(10)
    end


    AliyunHost.close_all_hosts
  end

end
