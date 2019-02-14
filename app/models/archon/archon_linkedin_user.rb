# encoding: utf-8
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
      ids =  []
      File.open(f).each do |id|
        next if id.blank?
        ids << id.strip
      end

      ids.each_slice(1000).each do |new_ids|
        users = ArchonLinkedinUser.select("experience").where(id: new_ids)
        users.each do |user|
          experience = user.experience
          JSON.parse(experience).each do |y|
            if y["companyName"]["Str"] == name
              data[y["title"]["Str"]] ||= 0
              data[y["title"]["Str"]] += 1
            end
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

  def self.linkedin_user_size
    2000
  end

  def self.user_names
    "alepitner,andrew-millar-76b82424,ron-moolenaar-3a5aa6b,james-chiang-50ab409,friend-walker-a3938657,cynthia-griffin-6b63b2142,adriennepfuentes,tpitner,katherine-munchmeyer-a0163b8,brian-davis-70b79360,rob-forden-92865156,richard-johnson-05a5186,k-andrew-wroblewski-b0a52370,miles-toder-a740a732,chris-pedersen-811a2725,travis-warner-57ba0a164,scott-shaw-3507814,david-penuel-884376173,william-klein-07aa6b73,francis-chip-peters-25913,benglerum,mason-yu-a26a5b51,zach-alger-bb14911b,jim-mullinax-0238001,clark-ledger-b9782a27,keith-lommel-9a34b421,geoff-benelisha,yvonne-%E4%BC%8A%E8%8A%B3-mcdowell-%E6%9D%9C%EF%BC%89-2138aa4,elizabethisaman,jennifer-khov-3a2b7190,christopher-smith-93589694,alan-clark-8556b4b7,nathanieltishman,justin-walls-95a4b8a,jonathanheimer,c-brendan-swartz-rpa-ams-cmca-5139632,sean-stein-b6721b1b,pauline-kao-127a319,danielle-koschil-37904b5,rtaylormoore,frank-valli-71125213,n-rashad-jones-b01bb01,gregory-may-ab2475135,brad-roberson-a5319212,daniel-phelps-3841888,baylor-duncan-216a62b9,bill-burns-2a757120,roseanne-freese-384a4a34,ivan-kamara-173199a,joe-plunkett-945abba2,wellington-chu-32a7961,kevin-fisher-44284956,adams-jonathan-41756435,dubray,suzanne-wong-777833,peter-mcsharry-a584045,raymond-greene-556038163,brent-christensen-78614713,luke-donohue-11b234a,gene-richards-35609950,jesse-curtis-6b67176,ryan-mckean-9a8b094,tony-hornik-tran-12524351,mark-petry-28416a85,carla-hitchcock-44348395,chris-miller-034880,erik-finch-84527513,jing-edwards-8662338,christian-marchant-a793109,john-lee-50592777,derek-bibler-1808582b,christopher-pater,thoshodges,ambassador-james-b-cunningham-b6861391,arlene-barilec-a98a137,paradisodx,kurt-tong-09b099b,darragh-paradiso-62682071,andrew-loftus-7a263054,chad-esch-84201924,jeffrey-shrader-b334744,timothy-hinman-240b352a,joshua-kim-bb07515b".split(",")
  end


  # nohup rails r ArchonLinkedinUser.dump_data_to_json &
  def self.dump_data_to_json
    datas = []
    unknow_hash = self.unknow_hash
    count = 0
    # ArchonLinkedinUser.where(id:user_names).each do |user|
    ArchonLinkedinUser.limit(1500).each do |user|
      user_info = user.get_linkedin_user_info
      userSkill = JSON.parse(user.skills).values.flatten.map{|x| x["skillName"]} rescue []
      # next if userSkill.blank?
      userAchievement = []
      education = user.get_linkedin_education
      career = user.get_linkedin_career
      # count += 1
      # break if count > linkedin_user_size
      data = {linkedIn: {}}
      linkedin = {}
      linkedin["user"] = user_info
      linkedin["userSkill"] = userSkill
      linkedin["userAchievement"] = userAchievement
      linkedin["education"] = education
      linkedin["career"] = career
      data[:linkedIn] = linkedin.merge(unknow_hash)
      $redis.sadd("archon_center_linkedin_datas", data.to_json)
    end

  end

  # nohup rails r ArchonLinkedinUser.read_redis_to_file &
  def self.read_redis_to_file
    time = Time.now.strftime("%Y%m%d%H%M%S")
    while true
      datas = []
      200.times do
        data = $redis.spop("archon_center_linkedin_datas")
        break if data.blank?
        datas << data
      end
      break if datas.blank?
      File.open("#{json_file_path}/#{time}_linkedin_data.json", "a+") {|f| f.puts datas}
    end
  end

  def get_linkedin_user_info
    latest_experience = JSON.parse(self.experience).sort_by{|x| x["timePeriod"]}.last rescue {}
    user_info = {
      "userId": self.id, #用户ID（用于唯一标定用户）
      "userName": self.name, #用户名称
      "userJob": "", #用户职业
      "userTitle": self.sub_desp, #用户头衔
      "userLocation": self.location, #用户地址
      "userTrade": (JSON.parse(self.contact)["industryName"] rescue nil), #用户所属行业
      "userOrgId": "", #用户所属公司ID
      "userOrgName": (JSON.parse(latest_experience["companyName"]["Raw"]) rescue nil), #用户公司
      "userIntroduction": self.desp, #用户简介
      "website": "https://www.linkedin.com/in/" + self.id, #string 个人linkedin页面地址
    }
    return user_info
  end


  def get_linkedin_education
    educations = JSON.parse(self.education) rescue []
    linkedin_education = []
    educations.each do |x|
      if x["timePeriod"].present?
        timePeriod = JSON.parse(x["timePeriod"]["Raw"]) rescue {}
        startDate = timePeriod["startDate"]["year"] rescue nil
        endDate = timePeriod["endDate"]["year"] rescue nil
      else
        startDate, endDate = nil, nil
      end
      linkedin_education << {
        "schoolName": x["schoolName"]["Str"], # str 学校
        "logo": x["schoolPic"], # str学校logo
        "degreeName": (JSON.parse(x["degreeName"]["Raw"]) rescue nil), # str学位
        "fieldOfStudy": (JSON.parse(x["fieldOfStudy"]["Raw"]) rescue nil), # str专业
        "startDate": startDate, # str入学时间
        "endDate": endDate, # str毕业时间
        "score": "", # str成绩
        "activities": "", # str活动社团
        "description": (x["description"] rescue nil), # str说明
      }
    end
    return linkedin_education
  end

  # ArchonLinkedinUser
  def get_linkedin_career
    linkedin_career = []
    experience = JSON.parse(self.experience) rescue []
    experience.each do |x|
      if x["timePeriod"].present?
        timePeriod = JSON.parse(x["timePeriod"]["Raw"]) rescue {}
        start_year = timePeriod["startDate"]["year"] rescue nil
        start_month = timePeriod["startDate"]["month"] rescue nil
        startDate = start_month.present? ? start_year.to_s + ("%02d" % start_month) : start_year.to_s
        end_year = timePeriod["endDate"]["year"] rescue nil
        end_month = timePeriod["endDate"]["month"] rescue nil
        endDate = end_month.present? ?  end_year.to_s +  ("%02d" % end_month) : end_year.to_s
      else
        startDate, endDate = nil, nil
      end
      linkedin_career << {
        "companyName":  (JSON.parse(x["companyName"]["Raw"]) rescue nil), # str 公司名称
        "logo": '', # str公司logo
        "locationName": (JSON.parse(x["locationName"]["Raw"]) rescue nil), # str公司位置
        "title": (JSON.parse(x["title"]["Raw"]) rescue nil), # str头衔
        "job": nil, # str职位
        "startDate": startDate,  # str入职时间
        "endDate": endDate, # str 离职时间
        "description": nil, # str职位描述
        "achievementFile": [] # str代表作，成就文件
      }
    end
    return linkedin_career
  end

  def self.json_file_path
    path = "#{Rails.root}/public/json_datas"
    unless Dir.exists? path
      FileUtils.mkdir_p path
    end
    return path
  end


  def self.unknow_hash
    {
      #机构信息
      "organization": [
        {
          "orgId": "", #机构ID（用于唯一标定机构）
          "orgName": "", #机构名称
          "orgField": "", #机构领域
          "orgIndustry": "", #机构行业
          "orgSize": "", #机构规模
          "orgIntruduction": "", #机构简介
          "orgWebsite": "", #机构网站
          "orgLocation": "", #机构总部
          "orgType": "" #机构类型
        },

      ],
      #人员机构关系
      "member": [
        {
          "orgId": "", #机构ID（用于标定机构和用户关系）
          "orgName": "", #机构名称
          "userId": "", #用户ID（用于标定机构和用户关系）
          "userName": "", #用户名称
        }
      ],
      #动态发布
      "post": [
        {
          "shareId": "", #动态id（唯一标定动态）
          "shareContent": "", #动态内容
          "userId": "", #发布者ID（用于标定动态和发布者关系）
          "userName": "", #发布者名称
          "shareTime": "", #发布时间
          "likeNum": "", #点赞个数
          "replayNum": "", #评论个数
          "visitUrl": nil, #原文信息URL
        }
      ],
      #动态评论
      "comment": [#被评论动态(回复)的作者ID
        {
          "shareId": "", #被评论主动态(回复)的id（用于标定被回复与被回复动态关系）
          "parentId": "", #被回复ID，用于回复的回复。
          "replyId": "", #回复id（唯一标定回复）
          "replyRecontent": "", #回复内容
          "userId": "", #回复者ID（用于标定回复与回复者关系）
          "userName": "", #回复者名称
          "replyTime": "", #回复时间
          "replyLinkNum": "", #回复的点赞数量
          "replyReplyNum": "", #回复的回复数量
        }
      ],
      #关注的人
      "followerMember": [
        {
          "userId": "", #被关注者ID（用于标定被关注者与关注者关系）
          "userName": "", #被关注者名称

        }

      ],
      #关注的机构、学校
      "followOrg": [
        {
          "orgId": "", #机构ID（用于标定被关注机构与关注者关系）
          "orgName": "", #机构名称
        }
      ],

      "others": {}
    }
  end


end
