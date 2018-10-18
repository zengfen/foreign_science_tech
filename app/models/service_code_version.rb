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
end
