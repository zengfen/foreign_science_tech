class MediumMailer < ApplicationMailer

	# MediumMailer.monitor_project(["xiaomengting@china-revival.com"]).deliver_now
	# def monitor_project(to_users)
 #    # {"国际传播项目"=>["重点媒体","主要媒体"],"全媒体工作平台项目"=>["一级"]} 
 #    @results = []
 #    project_level = {1=>[1],2=>[4,5]}

 #    current_date = (Time.now - 1.day).strftime("%Y%m%d")

 #    project_level.each do |project_id,project_level_id|
 #      conds = {}

 #      conds["sub_medium_levels.project_level_id"] = project_level_id
 #      conds["sub_medium_projects.project_id"] = project_id
 #      conds["sub_medium_counters.incr_count"] = 0
 #      conds["sub_medium_counters.current_date"] = current_date

 #      no_data = SubMedium.where(conds).includes([ :sub_medium_levels, :project_levels, :projects, :sub_medium_counters]).collect{|x| x.domain}.uniq

 #      levels = ProjectLevel.where(id: project_level_id).collect{|x| x.name}.join("/")
 #      result = {:title=>"#{x.name}-#{levels}",:no_data=>no_data}
      
 #      @results << result

 #    end

 #    conds = {} 
 #    conds["sub_medium_counters.incr_count"] = 0
 #    conds["id"] = [3806,2415] #businessnews.cn,theregister.co.uk
 #    special_media_no_data =  SubMedium.where(conds).includes([ :sub_medium_levels, :project_levels, :projects, :sub_medium_counters]).collect{|x| x.domain}
 #    special_media_no_data.each do |domain|
 #      @results << {:title=>"重点媒体",:no_data=>domain}
 #    end

 #  	mail to: to_users.join(';'), subject: "新闻媒体监控24小时无数据"

	# end

  # MediumMailer.monitor_project(["lijinmin@china-revival.com"]).deliver_now
  def monitor_project(to_users)
    sub_medium_ids = SubMediumLevel.where(project_level_id:[1,4,5]).collect{|x| x.sub_medium_id}.uniq
    sub_medium_ids += [3806,2415,2981,30040,2513,79,2486,3648, 3620, 3575, 3609, 3767, 30005, 3762, 60001, 60002, 2512, 60003, 30001, 60004, 30002, 3652, 3638, 60005, 2506, 3572, 3584]

    current_date = (Time.now - 1.day).strftime("%Y%m%d")


    conds = {}
    conds["id"] = sub_medium_ids
    conds["sub_medium_counters.incr_count"] = 0
    conds["sub_medium_counters.current_date"] = current_date

    @results = {}
    SubMedium.where(conds).includes([:sub_medium_counters]).each do |x|
      domain = []
      if @results[x.process_person].blank?
        domain = [x.domain]
      else
        domain = [@results[x.process_person]] + [x.domain]
      end
      @results.merge!({x.process_person=>domain.flatten.join(",")})
    end
    
    # result.each do |k,v|
    #   email = Employee.where(name:k).first.email rescue "xiaomengting@china-revival.com"
    #   MediumMailer.monitor_project(email,v).deliver_now
    # end
    mail to: to_users, subject: "新闻媒体监控24小时无数据"

  end



end