class ArchonThinkTank < ArchonBase

  def self.load_data
    File.open("/root/data.js","r").readlines.each do |line|
      doc = JSON.parse(line)
      id = Digest::MD5.hexdigest("#{doc["title"]}#{doc["created_at"]}")
      ArchonThinkTank.create({id:id,title:doc["title"],site:doc["site"],country:doc["country"],desp:doc["desp"],title_cn:doc["title_cn"],file_url:doc["pdf_url"],author:doc["author"],created_at:Time.parse(doc["created_at"]).to_i})
      ArchonThinkTankTag.create({pid:id,tag:236,created_at:Time.now.to_i})
    end
  end
end
