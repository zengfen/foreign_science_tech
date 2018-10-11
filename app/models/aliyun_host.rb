class AliyunHost < ApplicationRecord
  def self.need_reopen
    x = AliyunHost.first
    return true if x.blank?

    (x.created_at < 1.hour.ago)
  end

  def self.reopen_hosts(c = 1)
    AliyunHost.where("created_at < '#{1.day.ago}'").delete_all
    results = AliyunApi.create_instances(c)
    instance_ids = results["InstanceIdSets"]["InstanceIdSet"]
    puts instance_ids
    instance_ids.each do |x|
      AliyunHost.create(instance_id: x, is_disabled: false)
    end


    sleep(10)

    while true
      puts "wait"
      hosts = self.where(is_running: false)
      if hosts.count == 0
        break
      end

      hosts.each do |h|
        h.wait_ready
      end

      sleep(5)
    end

    need_closed = []
    self.where(is_disabled: false).each do |h|
      c = self.where(public_ip: h.public_ip).count
      if c > 1
        h.is_disabled = true
        h.save

        need_closed << h
      end
    end

    puts need_closed
    need_closed.each do |x|
      AliyunApi.delete_instance(x.instance_id)
    end

    return self.where(is_disabled: false).collect(&:public_ip)
  end

  def self.close_all_hosts
    self.all.each do |x|
      AliyunApi.delete_instance(x.instance_id)
      x.is_disabled = true
      x.save
    end
  end


  def wait_ready
    attr = AliyunApi.instance_attr(self.instance_id)
    self.public_ip = (attr["PublicIpAddress"]["IpAddress"] || []).first
    self.is_running = (attr["Status"] == "Running")
    self.save
  end

  def self.get_all_ips
    self.where(is_disabled: false).collect(&:public_ip)
  end


  def self.restart_agent(ips)
    $archon_redis.del('archon_current_command')
    $archon_redis.del('archon_host_commands')
    $archon_redis.del('archon_host_command_statuses')


    ips.each do |x|
      $archon_redis.hset('archon_host_commands', x, "agent_restart")
      $archon_redis.hset('archon_host_command_statuses', x, '')
    end
  end
end
