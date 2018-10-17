class NewSpiderCycleTask  < Base
  self.table_name = 'spider_cycle_tasks'


  def self.load
    filename = self.to_s.gsub("New", "") + ".rb"

    content = File.readlines("#{Rails.root}/db/#{filename}").join("")

    eval(content)
  end
end
