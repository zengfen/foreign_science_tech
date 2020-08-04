Timeout_vaule = 15

OpenTimeout_vaule = 15

module RestClient2

  def self.get(url, headers={}, &block)
    proxies = $proxy_list
    return nil if proxies.blank?
    proxies.each do |proxy|
      begin
        res = RestClient::Request.execute(
          :method => :get,
          :url => url,
          :headers => headers,
          :timeout => Timeout_vaule,
          :open_timeout => OpenTimeout_vaule,
          :proxy => proxy,
          :verify_ssl => false,
          &block)
        return res if res
      rescue
      end
    end
  end

  def self.get2(url, timeout, open_timeout)
    proxies = $proxy_list
    return nil if proxies.blank?
    proxies.each do |proxy|
      begin
        res = RestClient::Request.execute(
          :method => :get,
          :url => url,
          :timeout => timeout,
          :open_timeout => open_timeout,
          :proxy => proxy,
          :verify_ssl => false)
        return res if res
      rescue
      end
    end
  end


  def self.post(url, payload, headers={}, &block)

    RestClient::Request.execute(:method => :post, :url => url, :payload => payload, :headers => headers, :timeout => Timeout_vaule, :open_timeout => OpenTimeout_vaule, &block)

  end


  def self.patch(url, payload, headers={}, &block)

    RestClient::Request.execute(:method => :patch, :url => url, :payload => payload, :headers => headers, :timeout => Timeout_vaule, :open_timeout => OpenTimeout_vaule, &block)

  end


  def self.put(url, payload, headers={}, &block)

    RestClient::Request.execute(:method => :put, :url => url, :payload => payload, :headers => headers, :timeout => Timeout_vaule, :open_timeout => OpenTimeout_vaule, &block)

  end


  def self.delete(url, headers={}, &block)

    RestClient::Request.execute(:method => :delete, :url => url, :headers => headers, :timeout => Timeout_vaule, :open_timeout => OpenTimeout_vaule, &block)

  end


  def self.head(url, headers={}, &block)

    RestClient::Request.execute(:method => :head, :url => url, :headers => headers, :timeout => Timeout_vaule, :open_timeout => OpenTimeout_vaule, &block)

  end


  def self.options(url, headers={}, &block)

    RestClient::Request.execute(:method => :options, :url => url, :headers => headers, :timeout => Timeout_vaule, :open_timeout => OpenTimeout_vaule, &block)

  end


end