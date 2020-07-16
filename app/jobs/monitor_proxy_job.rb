class MonitorProxyJob < ApplicationJob
  queue_as :default

  def perform(*args)
    api_url = Setting.proxy_api["base_url"]
    bind_proxy_api_url = "#{api_url}/api/bind_proxy?project_name=#{ENV["ProjectName"]}"
    # bind_proxy_api_url = "#{api_url}/api/bind_proxy?project_name=test2"
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
        $proxy_list = JSON.parse(res.body)["datas"] rescue $default_proxy
      end
    end

    if inactive_proxy.present?
      to_users = [
        # 'lijinmin@china-revival.com',
        #          "xulei@china-revival.com",
        "zengfen@china-revival.com",
      ]
      ProxyMailer.inactive_monitor(to_users,inactive_proxy).deliver_now

    end




  end
end


