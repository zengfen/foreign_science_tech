class ServiceCode < ApplicationRecord
  def self.service_list
    ["archon_agent", "archon_supervisor", "archon_template"]
  end


  def self.init_all
    service_list.each do |x|
      c = ServiceCode.where(name: x).first
      next unless c.blank?


      ServiceCode.create(name: x)
    end
  end


  def do_compile(go_path, code_path, current_branch)
    `cd #{code_path}; git pull; git checkout #{current_branch}; git pull; go install`
    self.go_path = go_path
    self.code_path = code_path
    self.current_branch = current_branch
    self.save
  end
end
