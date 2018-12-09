class ArchonFacebookNameId  < ArchonBase
  def self.dump_all
    f = File.open("ArchonFacebookNameId.txt", "w")
    ArchonFacebookNameId.all.each do |x|
      f.puts "#{x.name}|||#{x.nid}"
    end

    f.close
  end
end
