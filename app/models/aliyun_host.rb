class AliyunHost < ApplicationRecord
  def self.need_reopen
    x = AliyunHost.first
    return true if x.blank?

    (x.created_at < 1.hour.ago)
  end

  def self.reopen_hosts(c = 1)
    results = AliyunApi.create_instances(c)
    instance_ids = results["InstanceIdSets"]["InstanceIdSet"]
    puts instance_ids
    instance_ids.each do |x|
      AliyunHost.create(instance_id: x)
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


    return self.all.collect(&:public_ip)
  end

  def self.close_all_hosts
    self.all.each do |x|
      AliyunApi.delete_instance(x.instance_id)
      x.destroy
    end
  end


  def wait_ready
    attr = AliyunApi.instance_attr(self.instance_id)
    self.public_ip = (attr["PublicIpAddress"]["IpAddress"] || []).first
    self.is_running = (attr["Status"] == "Running")
    self.save
  end
end
