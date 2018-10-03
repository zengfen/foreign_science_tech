class AliyunHost < ApplicationRecord
  def self.reopen_hosts(c = 1)
    results = AliyunApi.create_instances(c)
    instance_ids = results["InstanceIdSets"]["InstanceIdSet"]
    instance_ids.each do |x|
      AliyunHost.create(instance_id: x)
    end


    sleep(15)

    while true
      hosts = self.where(is_running: false)
      if hosts.count == 0
        break
      end
    end


  end

  def self.close_all_hosts
    self.all.each do |x|
      AliyunApi.delete_instance(x.instance_id)
    end
  end


  def wait_ready
  end
end
