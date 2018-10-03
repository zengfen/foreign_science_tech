class Hm
  def self.reopen
    AliyunHost.close_all_hosts
    ips = AliyunHost.reopen_hosts

    puts ips

    ControlTemplate.find(66).accounts.each do |x|
      x.remove_related_data
      x.valid_ips = ips
      x.save
      x.setup_redis
    end
  end
end
