class InitProxy
  def self.proxy_list
    $default_proxy = ["http://zhenhua:ZA12wsx@98.58.127.51:1587",
                      "http://zhenhua:ZA12wsx@173.255.255.38:1587"]
    bind_proxy_api_url = "https://archon-center.aggso.com/api/bind_proxy?project_name=#{ENV["ProjectName"]}"
    res = nil
    proxy_list = [nil] + $default_proxy
    proxy_list.each do |proxy|
      res = RestClient::Request.execute(
        :method => :get,
        :url => bind_proxy_api_url,
        :proxy => proxy,
        :verify_ssl => false) rescue nil
      if res.blank?
        next
      else
        break
      end
    end
    $proxy_list = JSON.parse(res.body)["data"] rescue $default_proxy
  end
end
InitProxy.proxy_list
