OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = 'TLSv1_2'
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] += ':DES-CBC3-SHA'
class GobMx
	def initialize
		@site = "墨西哥航天局"
		@prefix = "https://www.gob.mx"
		# RestClient.proxy = "http://192.168.112.1:1080/"
	end
	def list(body)
		tasks = []
		if body.blank?
			urls = ["https://www.gob.mx/aem/archivo/prensa?idiom=es","https://www.gob.mx/aem/archivo/articulos?idiom=es&filter_id=2179&filter_origin=archive","https://www.gob.mx/aem/archivo/videos?idiom=es"]
			urls.each do |url|
				puts body = {url:url}
				# tasks << {mode:"list",body:body}
				tasks << {mode:"list",body:URI.encode(body.to_json)}
			end
		else
			body = JSON.parse(URI.decode(body))
			# body = JSON.parse(body)
			url = body["url"]
			res = RestClient.get(url).body
			doc = Nokogiri::HTML(res)
			doc.search("article a.small-link").each do |one|
				puts link = one["href"]
				puts link = @prefix + link if !link.match(/^http/)
				if link.include? "gob"
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
		# link = "https://www.gob.mx/aem/es/articulos/dr-salvador-landeros-ayala-director-general-de-la-agencia-espacial-mexicana-integrante-del-consejo-consultivo-del-ift?idiom=es"
		res = RestClient.get(link).body
		doc = Nokogiri::HTML(res)
		title = doc.search("h1").inner_text.strip
		ts = doc.search("section.border-box").to_s.match(/\d+? de \w+? de 20\d{2}/).to_s.gsub("enero","January").to_s.gsub("febrero","February").to_s.gsub("marzo","March").to_s.gsub("abril","April").to_s.gsub("mayo","May").to_s.gsub("junio","June").to_s.gsub("julio","July").to_s.gsub("agosto","August").to_s.gsub("septiembre","September").to_s.gsub("octubre","October").to_s.gsub("noviembre","November").to_s.gsub("diciembre","December").to_s.gsub("de","/").to_s.gsub(" ","") rescue nil
	    puts time = Time.parse(ts)
	    # tt = Time.parse(time).to_i rescue nil
	    # ts = Time.at(tt) rescue nil
		author = []
		# doc.search("div.author-names a").each do |au|
		# 	author << au.inner_text.strip
		# end
		# author = author.compact.uniq
		desp = doc.search("div.article-body").search("p,li").collect{|x| x.inner_text.strip}.join("\n")
		videos = []
	      if link.to_s.match("videos")
	        puts id = doc.search("input.video-url").to_s.match(/value\=\"(.+?)\"/)[1]
	        ur = "https://www.youtube.com/get_video_info?video_id=#{id}"
	        	request_res = RestClient.get(ur)
				 urires = URI.decode(request_res.to_s)
				Rails.logger.info "**"*100
				# Rails.logger.info uriressplit = urires.split('"url":"')[1].split('","mimeType"')[0]
				# jsonres = JSON.parse(uriressplit)
				Rails.logger.info video_url = urires.split('"url":"')[1].split('","mimeType"')[0]
				Rails.logger.info viurl = URI.decode(URI.decode(video_url)).gsub('\u0026',"&")
	         videos << viurl

	      end
	     puts attached_media_info = ::Htmlarticle.download_medias(videos) 
		image = doc.search("div.pull-right img")[0][:src] rescue nil
		puts image = [image]
		puts images = ::Htmlarticle.download_images(image) 
		category = "人工智能技术、无人系统、平台技术、网络与信息技术、电子科学技术、量子技术、光学技术、动力能源技术、新材料与新工艺"
		task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: author, con_time: time, con_text: desp,attached_img_info: images, attached_media_info: attached_media_info, category: category}
		Rails.logger.info task
		puts task.to_json
		info = ::TData.save_one(task)
    	return info
	end
end