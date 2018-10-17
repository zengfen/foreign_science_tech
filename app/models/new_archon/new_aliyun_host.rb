class NewAliyunHost < Base
  self.table_name = 'aliyun_hosts'


  def self.load
    filename = self.to_s.gsub("New", "") + ".rb"

    content = File.readlines("#{Rails.root}/db/#{filename}").join("")

    eval(content)
  end
end
