class MediaInfoMailer < ApplicationMailer

	# MediaInfoMailer.monitor_one_level(["lijinmin@socialdatamax.com"]).deliver_now
	def monitor_one_level(to_users)
		domains = MediaInfo.select("domain").where({hav_infos:1,white_list:'0'}).where("level like '%#{1}%'").pluck("domain")
		domains += MediaInfo.select("domain").where({hav_infos:1,white_list:'0'}).where("level like '%#{0}%'").pluck("domain")

		interval_time = 24 * 3600
		monitor = MonitorDomainInfo.new({domains:domains.uniq,interval_time:interval_time})
		@no_data = monitor.monitor_have_data

		@title = "重点和一级媒体 24小时无数据"
		mail to: to_users.join(';'), subject: "重点和一级媒体监控"
	end

	# MediaInfoMailer.monitor_other_levels.deliver_now
	def monitor_other_levels(to_users)
		domains = MediaInfo.select("domain").where({hav_infos:1,white_list:'0'}).pluck("domain")
		one_or_im = MediaInfo.select("domain").where({hav_infos:1,white_list:'0'}).where("level like '%#{1}%'").pluck("domain")
		one_or_im += MediaInfo.select("domain").where({hav_infos:1,white_list:'0'}).where("level like '%#{0}%'").pluck("domain")
		domains = domains.uniq - one_or_im.uniq

		interval_time = 72 * 3600
		monitor = MonitorDomainInfo.new({domains:domains.uniq,interval_time:interval_time})
		@no_data = monitor.monitor_have_data

		@title = "其他媒体 72小时无数据"
		mail to: to_users.join(';'), subject: "其他媒体监控"		
	end

	# MediaInfoMailer.monitor_all_unnormal(["lijinmin@socialdatamax.com"]).deliver_now
	def monitor_all_unnormal(to_users)
		domains = MediaInfo.select("domain").where({hav_infos:1,white_list:'0'}).pluck("domain")

		monitor = MonitorDomainInfo.new({domains:domains.uniq})
		@abnormal_data = monitor.monitor_all_unnormal

		@title = "疑似异常的媒体"
		mail to: to_users.join(';'), subject: "所有疑似异常媒体"			
	end
end