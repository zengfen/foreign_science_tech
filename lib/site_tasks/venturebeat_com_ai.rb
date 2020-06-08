OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = 'TLSv1_2'
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] += ':DES-CBC3-SHA'
class VenturebeatComAi
	def initialize
		@site = "VentureBeat-AI"
		@prefix = "https://venturebeat.com"
		# RestClient.proxy = "http://10.119.12.12:1077/"
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
