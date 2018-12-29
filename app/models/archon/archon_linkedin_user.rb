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


  # ArchonLinkedinUser.dump_data_to_json
  def self.dump_data_to_json
    datas = []
    unknow_hash = self.unknow_hash
    count = 0
    ArchonLinkedinUser.find_each do |user|
      user_info = user.get_linkedin_user_info
      userSkill = JSON.parse(user.skills).values.flatten.map{|x| x["skillName"]} rescue []
      next if userSkill.blank?
      userAchievement = []
      education = user.get_linkedin_education
      career = user.get_linkedin_career
      count += 1
      break if count > 10
      data = {linkedIn: {}}
      linkedin = {}
      linkedin["user"] = user_info
      linkedin["userSkill"] = userSkill
      linkedin["userAchievement"] = userAchievement
      linkedin["education"] = education
      linkedin["career"] = career
      data[:linkedIn] = linkedin.merge(unknow_hash)
      datas << data.to_json
    end
    File.open("#{json_file_path}/linkedin_data.json", "a+") {|f| f.puts datas}

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
      "website": nil, #string 个人linkedin页面地址
    }
    puts "===user_info_id=====#{self.id}==="
    puts "===user_info=====#{user_info}==="
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
