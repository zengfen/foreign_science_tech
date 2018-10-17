class NewDispatcherHostServiceWorker  < Base
  self.table_name = 'host_service_workers'


  def self.load
    filename = self.to_s.gsub("New", "") + ".rb"

    content = File.readlines("#{Rails.root}/db/#{filename}").join("")

    eval(content)
  end
end
