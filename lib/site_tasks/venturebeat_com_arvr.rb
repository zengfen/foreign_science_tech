OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = 'TLSv1_2'
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] += ':DES-CBC3-SHA'
class VenturebeatComArvr
	def initialize
		@site = "VentureBeat-ARVR"
		@prefix = "https://venturebeat.com"
		# RestClient.proxy = "http://10.119.12.12:1077/"
	end
	def list(body)
		tasks = []
		if body.blank?
			urls = ["https://venturebeat.com/category/arvr/"]
			urls.each do |url|
				body = {url:url}
				tasks << {mode:"list",body:URI.encode(body.to_json)}
			end
		else
			# puts "---------------#{body}"
			body = JSON.parse(URI.decode(body))
			url = body["url"]
			# res = RestClient.get(url)
			res = RestClient::Request.execute(method: :get,url:url,verify_ssl: false)
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
		Rails.logger.info images = ::Htmlarticle.download_images(image_urls)
		files = []
		videos = []
		doc.search("span.embed-youtube iframe.youtube-player").each do |video|
			videos << video["src"]
		end
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