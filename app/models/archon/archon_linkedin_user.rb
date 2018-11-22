class ArchonLinkedinUser < ArchonBase
  def self.dump_user(name)
    user = ArchonLinkedinUser.find(name)
    user = user.to_json
    user = JSON.parse(user)
    user["id"] = 8097392
    user["linkedin_id"] = name
    user["experience"] = JSON.parse(user["experience"]) if !user["experience"].blank?
    user["contact"] = JSON.parse(user["contact"]) if !user["contact"].blank?
    user["skills"] = JSON.parse(user["skills"]) if !user["skills"].blank?
    user["education"] = JSON.parse(user["education"]) if !user["education"].blank?
    user["linkedin_connections"] =  user["connections"]
    user.delete("connections")
    user["gender"] = "male"
    user["birth_name"] = "William Henry Gates III(English)"
    user["family_name"] = "Gates"
    user["birthday"] = "28 October 1955"
    user["birth_place"] = "Seattle"
    user["relationship"] = [{relation:"father",value:"William H. Gates, Sr."},{relation:"mother",value:"Mary Maxwell Gates"},{relation:"spouse",value:"Melinda Gates"},{relation:"child",value:["Jennifer Katharine Gates","Phoebe Adele Gates","Rory John Gates"]}]
    user["blood_type"] = ""
    user["influenced_by"] = ""
    user["occupation"] = ["entrepreneur", "programmer", "computer scientist", "philanthropist", "inventor", "financier", "bridge player", "investor"]
    user["member_of"] = ["American Academy of Arts and Sciences", "National Academy of Engineering"]
    user["height"] = "1.77±0.01 metre"
    user["award_received"] = ["Knight Commander of the Order of the British Empire", "National Medal of Technology and Innovation", "Padma Bhushan", "National Medal of Technology and Innovation", "Cross of Recognition"]
    user["residence"] = "Medina"
    user["religion"] = "agnosticism"
    user["official_website"] = "http://www.thegatesnotes.com/"
    user["imdb_id"] = "nm0309540"
    user["facebook_id"] = "BillGates"
    user["freebase_id"] = "/m/017nt"
    user["quora_id"] = "Bill-Gates"
    user["youtube_channel_id"] = "UCnEiGCE13SUI7ZvojTAVBKw"
    user["instagram_id"] = "thisisbillgates"
    user["reddit_id"] = "thisisbillgates"
    user["sina_weibo_id"] = "gates"
    user["twitter_id"] = "BillGates"
    user["political_party"] = ""


    File.open("user_gate.json", "w") do |f|
      f.puts user.to_json
    end
  end


  def self.search_and_dump(keyword)
    f = File.open("us_users/#{keyword}.txt", "w")
    ArchonLinkedinUser.select("id").where("experience like '%\"Str\":\"#{keyword}\",%'").each do |x|
      f.puts x.id
    end

    f.close
  end


  def self.list_all_users
    data = {}
    Dir.glob("us_users/*.txt").each do |f|
      name = f.split("/").last.gsub(".txt", "")
      File.open(f).each do |id|
        next if id.blank?
        user = ArchonLinkedinUser.find(id.strip)
        experience = user.experience
        JSON.parse(experience).each do |y|
          if y["companyName"]["Str"] == name
            data[y["title"]["str"]] ||= 0
            data[y["title"]["str"]] += 1
          end
        end
      end
    end

    puts data

    File.open("army_group_title", "w") do |f|
      data.to_a.sort_by{|x| x[1]}.reverse.each do |x|
        f.puts "#{x[0]},#{x[1]}"
      end
    end
  end
end
