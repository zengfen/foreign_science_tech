OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = 'TLSv1_2'
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] += ':DES-CBC3-SHA'
class BbcComTech
	def initialize
		@site = "BBC-science"
		@prefix = "https://www.bbc.com"
		# RestClient.proxy = "http://10.119.12.12:1077/"
	end
	def list(body)
		tasks = []
		if body.blank?
			urls = ["https://www.bbc.com/news/technology"]
			urls.each do |url|
				body = {url:url}
				tasks << {mode:"list",body:URI.encode(body.to_json)}
			end
		else
			body = JSON.parse(URI.decode(body))
			url = body["url"]
			res = RestClient.get(url)
			doc = Nokogiri::HTML(res.body)
			doc.search("a.gs-c-promo-heading").each do |one|
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
		link = body["link"]
		res = RestClient.get(link).body
		doc = Nokogiri::HTML(res)
		title = doc.search("h1.story-body__h1,h1.primary-heading,header.lx-c-event-header h1").inner_text.strip
		ts = doc.to_s.match(/datePublished":"(.*?)",/)[1] rescue ""
		if ts == ""
			ts = doc.to_s.match(/publicationDate":"(.*?)",/)[1] rescue ""
		end
		time = Time.parse(ts) rescue nil
		params = {doc:doc,content_selector:"div.story-body__inner,div.primary-content div.primary-content-lining",html_replacer:"p||||li||||span||||br",content_rid_html_selector:"figure.media-landscape||||ul#follow-us-items||||span.share-item-text||||a.replace-image||||figure.media-with-caption"}
		desp,_ = ::Htmlarticle.get_html_content(params)
		# Rails.logger.info desp
		image_urls = []
		doc.search("div.story-body__inner img.js-image-replace,div.story-body__inner div.js-delayed-image-load").each do |img|
			image_urls << img["src"]
			image_urls << img["data-src"]
		end
		Rails.logger.info image_urls = image_urls.compact.uniq
		# Rails.logger.info image_urls
		images = ::Htmlarticle.download_images(image_urls)
		videos = []
		doc.search("div.sticky-player__player figure.media-player").each do |video|
			videos << video["data-playable"]
		end
		attached_media_info = ::Htmlarticle.download_medias(videos)
		files = []
		category = "新闻综合"
		author = []
		author << doc.search("div.byline span.byline__name").inner_text.strip.gsub("By ","") rescue nil
		author = author.compact.uniq
		task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: author, con_time: time, con_text: desp,attached_img_info: images,attached_file_info: files, category: category, attached_media_info: attached_media_info}
		Rails.logger.info task
		info = ::TData.save_one(task)
		return info
	end
end