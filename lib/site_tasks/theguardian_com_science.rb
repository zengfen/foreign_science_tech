class TheguardianComScience
	def initialize
		@site = "the guardian-science"
		@prefix = "https://www.theguardian.com"
		# RestClient.proxy = "http://10.119.12.2:1076/"
	end
	def list(body)
		tasks = []
		if body.blank?
			urls = ["https://www.theguardian.com/science"]
			urls.each do |url|
				body = {url:url}
				tasks << {mode:"list",body:URI.encode(body.to_json)}
			end
		else
			body = JSON.parse(URI.decode(body))
			url = body["url"]
			# res = RestClient::Request.execute(method: :get,url:url,verify_ssl: false)
			res = RestClient2.get(url)
			doc = Nokogiri::HTML(res.body)
			doc.search("a.js-headline-text,div.fc-item__container").each do |one|
				link = one["href"]
				link = @prefix + link if !link.match(/^http/)
				if link.include? "/science/"
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
	# 		urls = ["https://www.theguardian.com/science"]
	# 		urls.each do |url|
	# 			body = {url:url}
	# 			tasks << {mode:"list",body:URI.encode(body.to_json)}
	# 		end
	# 	else
	# 		body = JSON.parse(URI.decode(body))
	# 		page = 1
	# 		while page < 40
	# 			url = "https://www.theguardian.com/science?page=#{page}"
	# 			res = RestClient::Request.execute(method: :get,url:url,verify_ssl: false)
	# 			doc = Nokogiri::HTML(res.body)
	# 			doc.search("a.js-headline-text").each do |one|
	# 				link = one["href"]
	# 				link = @prefix + link if !link.match(/^http/)
	# 				if link.include? "/science/"
	# 					body = {link:link}
	# 					tasks << {mode:"item",body:URI.encode(body.to_json)}
	# 				end
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
		res = RestClient2.get(link).body
		# res = RestClient::Request.execute(method: :get,url:link,verify_ssl: false).body
		doc = Nokogiri::HTML(res)
		Rails.logger.info title = doc.search("div.gs-container h1,h1.css-rtdfvn").inner_text.strip
		Rails.logger.info ts = doc.search("meta[property='article:published_time']")[0]["content"] rescue nil
		time = Time.parse(ts) rescue nil
		author = []
		doc.search("div.meta__contact-wrap p.byline a.tone-colour").each do |au|
			author << au.inner_text.strip
		end
		author = author.compact.uniq
		params = {doc:doc,content_selector:"div.content__standfirst li,div.content__standfirst p,div.content__article-body p",html_replacer:"p||||li",content_rid_html_selector:"p.content__standfirst a.u-underline"}
		desp,_ = ::Htmlarticle.get_html_content(params)
		desp = desp.gsub("How to listen to podcasts: everything you need to know","")
		attached_media_info = []
		doc.search("div.youtube-media-atom__iframe").each do |video|
			if video["src"].include? "youtube"
				src = video["src"]
				Rails.logger.info video_id = src.to_s.split("embed/")[1].split("?")[0]
				request_url = "https://www.youtube.com/get_video_info?video_id=#{video_id.to_s}"
				request_res = RestClient2.get(request_url)
				urires = URI.decode(request_res.to_s)
				Rails.logger.info "**"*100
				# Rails.logger.info uriressplit = urires.split('"url":"')[1].split('","mimeType"')[0]
				# jsonres = JSON.parse(uriressplit)
				Rails.logger.info video_url = urires.split('"url":"')[1].split('","mimeType"')[0]
				Rails.logger.info viurl = URI.decode(URI.decode(video_url)).gsub('\u0026',"&")
				attached_media_info << viurl
			else
				attached_media_info << video["src"]
			end
			attached_media_info << "https://www.youtube.com/embed/"+video["data-asset-id"]
		end
		doc.search("div.podcast figure.podcast__player").each do |audio|
			attached_media_info << audio["data-download-url"]
		end
		Rails.logger.info attached_media_info
		attached_media_infos = ::Htmlarticle.download_medias(attached_media_info)
		image_urls = []
		doc.search("img.maxed.responsive-img,div.u-responsive-ratio img.gu-image").each do |img|
			image_urls << img["src"]
		end
		Rails.logger.info image_urls
		images = ::Htmlarticle.download_images(image_urls)
		category = "新闻综合"
		attached_file_info = []
		task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: author, con_time: time, con_text: desp,attached_img_info: images.compact.uniq, attached_media_info: attached_media_infos.compact.uniq, category: category, attached_file_info: attached_file_info}
		Rails.logger.info task
		info = ::TData.save_one(task)
    	return info
	end
end
