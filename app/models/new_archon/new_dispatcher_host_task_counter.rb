class NewDispatcherHostTaskCounter  < Base
  self.table_name = 'host_task_counters'


  def self.load
    filename = self.to_s.gsub("New", "") + ".rb"

    content = File.readlines("#{Rails.root}/db/#{filename}").join("")

    eval(content)
  end
end
