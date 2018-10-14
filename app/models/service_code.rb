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
end
