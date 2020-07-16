class InitProxy
  def self.proxy_list
    $default_proxy = ["http://zhenhua:ZA12wsx@198.58.127.51:1587",
                      "http://zhenhua:ZA12wsx@173.255.255.38:1587"]
    api_url = Setting.proxy_api["base_url"]
    bind_proxy_api_url = "#{api_url}/api/bind_proxy?project_name=#{ENV["ProjectName"]}"
    # bind_proxy_api_url = "#{api_url}/api/bind_proxy?project_name=test1"
    res = nil
    proxy_list = [nil] + $default_proxy
    proxy_list.each do |proxy|
      res = RestClient::Request.execute(
        :method => :get,
        :url => bind_proxy_api_url,
        :proxy => proxy,
        :verify_ssl => false,
        :timeout => 15,
        :open_timeout => 15,) rescue nil
      if res.blank?
        next
      else
        break
      end
    end
    $proxy_list = JSON.parse(res.body)["datas"] rescue nil
    $proxy_list = $default_proxy if $proxy_list.blank?
  end
end
InitProxy.proxy_list
