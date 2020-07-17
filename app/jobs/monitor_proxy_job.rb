class MonitorProxyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    api_url = Setting.proxy_api["base_url"]
    bind_proxy_api_url = "#{api_url}/api/bind_proxy?project_name=#{ENV["ProjectName"]}"
    # bind_proxy_api_url = "#{api_url}/api/bind_proxy?project_name=test4"
    inactive_proxy = []
    $proxy_list.each do |proxy|
      res = RestClient::Request.execute(
        :method => :get,
        :url => bind_proxy_api_url,
        :proxy => proxy,
        :verify_ssl => false,
        :timeout => 10,
        :open_timeout => 10,) rescue nil
      if res.blank?
        inactive_proxy << proxy if proxy.present?
        next
      else
        $proxy_list = JSON.parse(res.body)["datas"] rescue nil
        $proxy_list = $default_proxy if $proxy_list.blank?
      end
    end

    if inactive_proxy.present?
      to_users =["zhaoyuting@china-revival.com",
                 "zengfen@china-revival.com",
                 "fanglongqing@china-revival.com",
                 "caobaishun@china-revival.com",
                 "haobaozhi@china-revival.com",
                 "xulei@socialdatamax.com",
                 "baomingdong@china-revival.com",
                 "penghao@china-revival.com",
                 "yuanrunze@china-revival.com",
                 "jiawenqi@china-revival.com"]
      ProxyMailer.inactive_monitor(to_users,inactive_proxy).deliver_now

    end




  end
end


