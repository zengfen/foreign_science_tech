class VenturebeatComAi
	def initialize
		@site = "VentureBeat-AI"
		@prefix = "https://venturebeat.com"
		# RestClient.proxy = "http://10.119.12.2:1076/"
	end
	def list(body)
		tasks = []
		if body.blank?
			urls = ["https://venturebeat.com/category/ai/"]
			urls.each do |url|
				body = {url:url}
				tasks << {mode:"list",body:URI.encode(body.to_json)}
			end
		else
			# puts "---------------#{body}"
			body = JSON.parse(URI.decode(body))
			url = body["url"]
			# res = RestClient.get(url)
			res = RestClient::Request.execute(method: :get,url:url,verify_ssl: false,:timeout =>10,:open_timeout =>10
			)
			doc = Nokogiri::HTML(res.body)
			doc.search("a.article-title-link,h2.article-title a").each_with_index do |one|
				link = one["href"]
				link = @prefix + link if !link.match(/^http/)
				if !link.match(/\d{4}\/\d{2}\/\d{2}/).nil?
					body = {link:link}
					tasks << {mode:"item",body:URI.encode(body.to_json)}
				end
			end
		end
		return tasks
	end
	# def list(body)
	# 	tasks = []
	# 	if body.blank?
	# 		urls = ["https://venturebeat.com/category/ai/"]
	# 		urls.each do |url|
	# 			body = {url:url}
	# 			tasks << {mode:"list",body:URI.encode(body.to_json)}
	# 		end
	# 	else
	# 		# puts "---------------#{body}"
	# 		body = JSON.parse(URI.decode(body))
	# 		# url = body["url"]
	# 		url = "https://venturebeat.com/wp-admin/admin-ajax.php"
	# 		page = 2
	# 		header = {
	# 			"authority"=> "venturebeat.com",
	# 			"method"=> "POST",
	# 			"path"=> "/wp-admin/admin-ajax.php",
	# 			"scheme"=> "https",
	# 			"accept"=> "application/json, text/javascript, */*; q=0.01",
	# 			# "accept-encoding"=> "gzip, deflate, br",
	# 			"accept-language"=> "zh-CN,zh;q=0.9",
	# 			"content-length"=> "68",
	# 			"content-type"=> "application/x-www-form-urlencoded; charset=UTF-8",
	# 			"cookie"=> "__gads=ID=d3834bd5aa189eb8:T=1591005459:S=ALNI_MaJR2GrjFw6dh95gbtoTd2b5pfIaw; _fbp=fb.1.1591068631518.1079513295; _scp=1591077836537.2035036773; ac_user_id=acuyhpjytblkxz44468f7b2525249eec153ca23e5f7d3961b5e07dcaebd4b44152d2766ad107faa; __browsiUID=7e8ff057-01da-4b3f-a333-7c7535528618; __qca=P0-1427954703-1591078016906; _gid=GA1.2.1872026067.1591584027; _scs=1591584027090.242888378; GED_PLAYLIST_ACTIVITY=W3sidSI6IkdGMzciLCJ0c2wiOjE1OTE2MDYwODksIm52IjowLCJ1cHQiOjE1OTE2MDU4NjgsImx0IjoxNTkxNjA1ODY4fV0.; bounceClientVisit3962v=N4IgNgDiBcIBYBcEQM4FIDMBBNAmAYnvgG4CmAdggK4BOpARqQIYIB0AxgPYC2R7LpAOacaATyJMAlkRAAaEDRggQAXyA; mnet_session_depth=2%7C1591621114103; __browsiSessionID=a0f1fb82-123b-4c43-adb4-381f12e96e13&true&false&DEFAULT&cn&desktop-1.39.3&false; _ga=GA1.1.1854386628.1591005305; _ga_SCH1J7LNKY=GS1.1.1591621143.16.1.1591621268.0",
	# 			"origin"=> "https://venturebeat.com",
	# 			"referer"=> "https://venturebeat.com/category/ai/",
	# 			"sec-fetch-dest"=> "empty",
	# 			"sec-fetch-mode"=> "cors",
	# 			"sec-fetch-site"=> "same-origin",
	# 			"user-agent"=> "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36",
	# 			"x-requested-with"=> "XMLHttpRequest",
	# 		}
			
	# 		while page<6
	# 			postdata = {
	# 				"action" => "channel_load_more",
	# 				"channel_nonce" => "10a016d899",
	# 				"paged" => page,
	# 				"channel" => "ai"
	# 			}
	# 			Rails.logger.info res = RestClient.post(url,postdata,header=header).body
	# 			jsonres = JSON.parse(res)
	# 			jsonres.each do |json|
	# 				# if json["time"].to_s.include? "2020"
	# 					link = json["permalink"]
	# 					link = @prefix + link if !link.match(/^http/)
	# 					if !link.match(/\d{4}\/\d{2}\/\d{2}/).nil?
	# 						body = {link:link}
	# 						tasks << {mode:"item",body:URI.encode(body.to_json)}
	# 					end
	# 					Rails.logger.info link
	# 				# end
	# 			end
	# 			page = page + 1
	# 		end
	# 	end
	# 	return tasks
	# end
	def item(body)
		body = JSON.parse(URI.decode(body))
		puts link = body["link"]
		# puts link = "https://venturebeat.com/2020/06/01/argo-closes-2-6-billion-round-from-vw-at-a-7-25-billion-valuation/"
		res = RestClient.get(link).body
		# res = RestClient::Request.execute(method: :get,url:link,verify_ssl: false).body
		doc = Nokogiri::HTML(res)
		puts title = doc.search("header.article-header h1.article-title").inner_text.strip
		puts ts = doc.search("meta[property='article:published_time']")[0]["content"].to_s
		puts time = Time.parse(ts)
		params = {doc:doc,content_selector:"div#content div.article-content",html_replacer:"p",content_rid_html_selector:"div.wp-caption p.wp-caption-text||||div.post-boilerplate"}
		desp,_ = ::Htmlarticle.get_html_content(params)
		puts desp
		image_urls = []
		doc.search("div.article-media-header img,img.aligncenter.size-large").each do |img|
			image_urls << img["src"]
		end
		image_urls = image_urls.compact.uniq
		puts image_urls
		Rails.logger.info "------------------------"
		Rails.logger.info images = ::Htmlarticle.download_images(image_urls)
		files = []
		videos = []
		doc.search("span.embed-youtube iframe.youtube-player").each do |video|
			if video["src"].include? "youtube"
				src = video["src"]
				Rails.logger.info video_id = src.to_s.split("embed/")[1].split("?")[0]
				request_url = "https://www.youtube.com/get_video_info?video_id=#{video_id.to_s}"
				request_res = RestClient.get(request_url)
				urires = URI.decode(request_res.to_s)
				Rails.logger.info "**"*100
				# Rails.logger.info uriressplit = urires.split('"url":"')[1].split('","mimeType"')[0]
				# jsonres = JSON.parse(uriressplit)
				Rails.logger.info video_url = urires.split('"url":"')[1].split('","mimeType"')[0]
				Rails.logger.info viurl = URI.decode(URI.decode(video_url)).gsub('\u0026',"&")
				videos << viurl
			else
				videos << video["src"]
			end
			
		end
		# videos << "https://r2---sn-a5mlrn7z.googlevideo.com/videoplayback?expire=1591613266&ei=8sLdXs7qCoiskga_pbjYBg&ip=170.178.190.146&id=o-AOeqy4YoTdb66OUQw_Ymzzdcg7Y6bwuDIJR2hoQa4lJ9&itag=398&aitags=133,134,135,136,137,160,242,243,244,247,248,271,278,313,394,395,396,397,398,399&source=youtube&requiressl=yes&mh=ZS&mm=31,26&mn=sn-a5mlrn7z,sn-n4v7sney&ms=au,onr&mv=m&mvi=1&pl=24&initcwndbps=4010000&vprv=1&mime=video/mp4&gir=yes&clen=4305660&dur=77.099&lmt=1591516668804119&mt=1591591595&fvip=2&keepalive=yes&fexp=23882513&c=WEB&txp=5531432&sparams=expire,ei,ip,id,aitags,source,requiressl,vprv,mime,gir,clen,dur,lmt&sig=AOq0QJ8wRgIhAM8KGJQ3Qovtq-KfAC92ytu5y7oQaUSv0YuAWwT-GnI9AiEAt_gARKv9F5oii5P8W3Ut1r37XX3FXguI6Wrpkw9L5vw=&lsparams=mh,mm,mn,ms,mv,mvi,pl,initcwndbps&lsig=AG3C_xAwRgIhAMmBAPmJ6_-ENROE_h34TVf8w0dc16wzErTZG3efVQYHAiEAuelpWdb2UEOUf3YI2fhMWqntvanwUUEfJHi-7SZOGt4="
		videos = videos.compact.uniq
		Rails.logger.info videos
		# Rails.logger.info "--------------"
		attached_media_info = ::Htmlarticle.download_medias(videos)
		category = "人工智能"
		# doc.search("")
		author = []
		puts author << doc.search("div.article-byline a.author").inner_text.strip rescue nil
		author = author.compact.uniq
		task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: author, con_time: time, con_text: desp,attached_img_info: images,attached_file_info: files, category: category, attached_media_info: attached_media_info}
		Rails.logger.info task
		info = ::TData.save_one(task)
    	return info
	end
end
