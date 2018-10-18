class ServiceCodeVersion < ApplicationRecord
  def self.version_name_list
    {
      "all_file" => "Agent全部文件",
      "supervisor_file" => "Supervisor文件",
      "agent_template_file" => "Agent模板更新文件",
    }
  end


  def self.init_all
    version_name_list.each do |x, _ |
      c = ServiceCodeVersion.where(name: x).first
      next unless c.blank?

      ServiceCodeVersion.create(name: x)
    end
  end


  def name_cn
    self.class.version_name_list[self.name]
  end


  def file_name
    Digest::MD5.hexdigest(self.name) + ".tar.gz"
  end

  def do_package_and_upload
    go_path = ServiceCode.first.go_path + "/bin"

    if self.name == "all_file"
      `cd #{go_path}; rm #{self.file_name}; tar zcvf #{self.file_name} archon_agent archon_template archon_supervisor`
    end

    if self.name == "supervisor_file"
      `cd #{go_path}; rm #{self.file_name}; tar zcvf #{self.file_name} archon_supervisor`
    end

    if self.name == "agent_template_file"
      `cd #{go_path}; rm #{self.file_name}; tar zcvf #{self.file_name} archon_agent archon_template`
    end
    self.file_path = "#{go_path}/#{self.file_name}"
    self.sha1_code = `sha1sum #{self.file_path}`.split(" ").first
    self.save



    bucket = $oss_client_e.get_bucket(AliyunEBucket)
    if bucket.object_exists?(self.file_name)
      bucket.delete_object(self.file_name)
    end
    bucket.put_object(self.file_name, :file => self.file_path)
    bucket_url = bucket.object_url(self.file_name).split("?").first + "\n" + self.sha1_code

    if self.name == "all_file"
      $archon_redis.set("AgentGetAllPackFile_external", bucket_url)
    end
    if self.name == "supervisor_file"
      $archon_redis.set("AgentGetSupervisorFile_external", bucket_url)
    end
    if self.name == "agent_template_file"
      $archon_redis.set("AgentGetAgentAndTemplateFile_external", bucket_url)
    end


    bucket = $oss_client_i.get_bucket(AliyunIBucket)
    if bucket.object_exists?(self.file_name)
      bucket.delete_object(self.file_name)
    end
    bucket.put_object(self.file_name, :file => self.file_path)
    bucket_url = bucket.object_url(self.file_name).split("?").first + "\n" + self.sha1_code

    if self.name == "all_file"
      $archon_redis.set("AgentGetAllPackFile_internal", bucket_url)
    end
    if self.name == "supervisor_file"
      $archon_redis.set("AgentGetSupervisorFile_internal", bucket_url)
    end
    if self.name == "agent_template_file"
      $archon_redis.set("AgentGetAgentAndTemplateFile_internal", bucket_url)
    end

  end
end
