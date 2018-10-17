class NewDispatcherTaskResultCounter  < Base
  self.table_name = 'task_result_counters'


  def self.load
    filename = self.to_s.gsub("New", "") + ".rb"

    content = File.readlines("#{Rails.root}/db/#{filename}").join("")

    eval(content)
  end
end
