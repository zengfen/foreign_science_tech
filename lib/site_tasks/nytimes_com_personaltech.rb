class NytimesComPersonaltech
	def initialize
		@site = "纽约时报-tech-personal tech"
		@prefix = "https://www.nytimes.com"
		# RestClient.proxy = "http://10.119.12.234:1077/"
	end
	def list(body)
		tasks = []
		if body.blank?
			urls = ["https://www.nytimes.com/section/technology/personaltech"]
			urls.each do |url|
				body = {url:url}
				tasks << {mode:"list",body:URI.encode(body.to_json)}
			end
		else
			body = JSON.parse(URI.decode(body))
			url = body["url"]
			res = RestClient2.get(url)
			doc = Nokogiri::HTML(res.body)
			doc.search("ol.ekkqrpp2 li.ekkqrpp3 h2 a,div.css-13mho3u li.css-ye6x8s a").each do |one|
				link = one["href"]
				link = @prefix + link if !link.match(/^http/)
				body = {link:link}
				tasks << {mode:"item",body:URI.encode(body.to_json)}
			end
		end
		return tasks
	end
	def item(body)
		body = JSON.parse(URI.decode(body))
		puts link = body["link"]
		# puts link = "https://venturebeat.com/2020/06/01/argo-closes-2-6-billion-round-from-vw-at-a-7-25-billion-valuation/"
		res = RestClient2.get(link).body
		# res = RestClient::Request.execute(method: :get,url:link,verify_ssl: false).body
		doc = Nokogiri::HTML(res)
		Rails.logger.info title = doc.search("div.css-1vkm6nb h1,h1#interactive-heading,h1.story-heading").inner_text.strip
		ts = doc.search("meta[property='article:published']")[0]["content"].to_s rescue nil
		Rails.logger.info time = Time.parse(ts) rescue nil
		author = []
		author << doc.search("div.css-1baulvz span.last-byline,p#interactive-byline span.last-byline,p.byline-dateline span.byline-author").inner_text.strip
		Rails.logger.info author
		params = {doc:doc,content_selector:"section.meteredContent p.css-158dogj,div.g-story p.g-body,div.g-graphic p.g-body",html_replacer:"p",content_rid_html_selector:""}
		desp,_ = ::Htmlarticle.get_html_content(params)
		Rails.logger.info desp
		image_urls = []
		doc.search("figure.sizeLarge.layoutHorizontal,figure.css-jcw7oy.e1g7ppur0").each do |img|
			image_urls << img["itemid"]
		end
		Rails.logger.info image_urls
		images = ::Htmlarticle.download_images(image_urls)
		videos = []
		doc.search("figure video.cinemagraph_video").each do |video|
			videos << video["src"]
		end
		Rails.logger.info videos
		attached_media_infos = ::Htmlarticle.download_medias(videos)
		category = "人工智能技术、无人系统、平台技术、网络与信息技术、电子科学技术、"
		task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,attached_media_infos:attached_media_infos,con_title:title, con_author: author, con_time: time, con_text: desp,attached_img_info: images.compact.uniq, category: category}
		Rails.logger.info task
		info = ::TData.save_one(task)
    	return info
	end
end