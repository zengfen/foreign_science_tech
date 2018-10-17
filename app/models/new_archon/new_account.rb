class NewAccount < Base
  self.table_name = 'accounts'


  def self.load
    filename = self.class.to_s.gsub("New", "") + ".rb"

    content = File.readlines("#{Rails.root}/db/#{filename}").join("")

    eval(content)
  end
end
