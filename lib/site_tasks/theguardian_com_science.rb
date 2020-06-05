class TheguardianComScience
	def initialize
		@site = "the guardian-science"
		@prefix = "https://www.theguardian.com"
		# RestClient.proxy = "http://10.119.12.234:1077/"
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
			res = RestClient::Request.execute(method: :get,url:url,verify_ssl: false)
			doc = Nokogiri::HTML(res.body)
			doc.search("a.js-headline-text").each do |one|
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
	def item(body)
		body = JSON.parse(URI.decode(body))
		puts link = body["link"]
		# puts link = "https://venturebeat.com/2020/06/01/argo-closes-2-6-billion-round-from-vw-at-a-7-25-billion-valuation/"
		res = RestClient.get(link).body
		# res = RestClient::Request.execute(method: :get,url:link,verify_ssl: false).body
		doc = Nokogiri::HTML(res)
		Rails.logger.info title = doc.search("div.gs-container h1").inner_text.strip
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
			attached_media_info << "https://www.youtube.com/embed/"+video["data-asset-id"]
		end
		doc.search("div.podcast figure.podcast__player").each do |audio|
			attached_media_info << audio["data-download-url"]
		end
		image_urls = []
		doc.search("img.maxed.responsive-img,div.u-responsive-ratio img.gu-image").each do |img|
			image_urls << img["src"]
		end
		# Rails.logger.info image_urls
		images = ::Htmlarticle.download_images(image_urls)
		category = "新闻综合"
		task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: author, con_time: time, con_text: desp,attached_img_info: images.compact.uniq, attached_media_info: attached_media_info.compact.uniq, category: category}
		Rails.logger.info task
		info = ::TData.save_one(task)
    	return info
	end
end