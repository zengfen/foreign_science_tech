# encoding: utf-8

class AliyunApi
  #  us-west-1
  def self.regions
    return make_request({:Action => "DescribeRegions"})
  end

  def self.images(region_id)
    return make_request({:Action => "DescribeImages", :RegionId => region_id, :PageSize => "50" })
  end

  def self.instances(region_id, page = 1, per_page = 10)
    return make_request({:Action => "DescribeInstanceStatus", :RegionId => region_id, :PageNumber => page.to_s, :PageSize => per_page.to_s})
  end

  def self.create_instances(c = 1)
    return make_request({:Action => "RunInstances",
                         :RegionId => "us-west-1",
                         :ZoneId => "us-west-1b",
                         :ImageId => "m-rj9a3ceu03qxn538ioay",
                         :InstanceType => "ecs.n1.tiny",
                         :SecurityGroupId => "sg-u16i9xyyd",
                         :InstanceChargeType => "PostPaid",
                         :InternetChargeType => "PayByBandwidth",
                         :InternetMaxBandwidthOut => 1.to_s,
                         :Amount => c.to_s,
                         :PasswordInherit => "true",

    })
  end

  def self.instance_types
    return make_request({:Action => "DescribeInstanceTypes"})
  end

  def self.security_groups(region_id)
    return make_request({:Action => "DescribeSecurityGroups", :RegionId => region_id})
  end

  # def self.create_instance(region_id, image_id, instance_type, security_group_id, password)
  #   return make_request({:Action => "CreateInstance", :RegionId => region_id, :ImageId => image_id, :InstanceType => instance_type, :SecurityGroupId => security_group_id, :Password => password, :InternetMaxBandwidthIn => "1", :InternetMaxBandwidthOut => "1"})
  # end

  def self.stop_instance(instance_id, is_force = false)
    return make_request({:Action => "StopInstance", :InstanceId => instance_id, :ForceStop => is_force.to_s})
  end

  def self.instance_attr(instance_id)
    return make_request({:Action => "DescribeInstanceAttribute", :InstanceId => instance_id})
  end

  def self.start_instance(instance_id)
    return make_request({:Action => "StartInstance", :InstanceId => instance_id})
  end

  def self.delete_instance(instance_id)
    return make_request({:Action => "DeleteInstance", :InstanceId => instance_id, :Force => "true"})
  end

  def self.allocate_public_ip(instance_id)
    return make_request({:Action => "AllocatePublicIpAddress", :InstanceId => instance_id})
  end

  def self.reboot_instance(instance_id, is_force = false)
    return make_request({:Action => "RebootInstance", :InstanceId => instance_id, :ForceStop => is_force.to_s})
  end

  def self.make_request(req_params)
    api_http_method = "GET"
    api_version = "2014-05-26"
    api_key = "ZeYymZ4l5LYsMdCe"
    api_secret = "k07G51MNpN0GeGfQ8Kru1pzg8FG1ny"
    api_timestamp = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    api_sign_method = "HMAC-SHA1"
    api_sign_version = "1.0"
    api_sign_nonce = Digest::MD5.hexdigest(Time.now.to_f.to_s)
    api_format = "JSON"

    params = {}
    # params[:Action] = req_action
    params[:Version] = api_version
    params[:AccessKeyId] = api_key
    params[:TimeStamp] = api_timestamp
    params[:SignatureMethod] = api_sign_method
    params[:SignatureVersion] = api_sign_version
    params[:SignatureNonce] = api_sign_nonce
    params[:Format] = api_format

    params.merge!(req_params)
    # puts params

    sort_params = params.sort
    sign_string = "#{api_http_method}&#{CGI.escape('/')}&"
    sign_string_new = ""
    sort_params.each do |x|
      sign_string_new << "&#{CGI.escape(x[0].to_s)}=#{CGI.escape(x[1]).to_s}"
    end

    sign_string << CGI.escape(sign_string_new[1..-1])
    # puts sign_string

    signature = OpenSSL::HMAC.digest("sha1","#{api_secret}&",  sign_string).to_s
    signature = Base64.encode64(signature).strip
    params[:Signature] = signature

    req_params_string = params.to_a.collect{|x| "#{x[0]}=#{CGI.escape(x[1])}"}.join("&")


    return JSON.parse(RestClient.get("https://ecs.aliyuncs.com/?#{req_params_string}").body)
  end


end
