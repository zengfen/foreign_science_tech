OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = 'TLSv1_2'
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] += ':DES-CBC3-SHA'
class WashingtonpostCom
	def initialize
		@site = "华盛顿邮报-科技-创新科技"
		@prefix = "https://www.washingtonpost.com"
		# RestClient.proxy = "http://192.168.112.1:1080/"
	end
	def list(body)
		tasks = []
		if body.blank?
			urls = ["https://www.washingtonpost.com/news/innovations/"]
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
			doc.search("div.story-list h2 a").each do |one|
				puts link = one["href"]
				puts link = @prefix + link if !link.match(/^http/)
				if link.include? "washingtonpost"
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
		# link = "https://www.washingtonpost.com/technology/2019/11/18/banking-that-electric-cars-can-also-be-cool-ford-introduces-an-all-electric-mustang/"
		res = RestClient.get(link).body
		doc = Nokogiri::HTML(res)
		puts title = doc.search("header h1").inner_text.strip
		tss = doc.search("article div.display-date").inner_text rescue nil
	    time = Time.parse(tss).to_s rescue nil
	    tt = Time.parse(time).to_i rescue nil
	    puts ts = Time.at(tt) rescue nil
		author = []
		doc.search("div.byline div.author-names a.author-name-link").each do |au|
			au = au.search("span").inner_text.strip
			author << au if au != ""
		end
		puts author = author.compact.uniq
		puts desp = doc.search("div.article-body").search("p").collect{|x| x.inner_text.strip}.join("\n")
		attached_media_info = []
	      if doc.search("figure div.powa-skip").to_s.match("uuid")
	         id1 = doc.search("figure div.powa-skip").to_s.match(/uuid\=\"(.+?)\"/)[1]
	         id2 = id1.to_s.gsub("-","")
	        ur = "https://video-api.washingtonpost.com/api/v1/ansvideos/findByUuid?uuid=#{id1}&cb=powaCallback#{id2}"
	         st = RestClient.get(ur).body
	         stt = st.to_s.match(/\((.+?)\)\;/)[1]
	         docc = JSON.parse(stt)
	        puts shi = docc[0]["streams"][-1]["url"]
	         attached_media_info << shi

	      end
	     puts attached_media_info = ::Htmlarticle.download_medias(attached_media_info) 
		images = doc.search("figure img")[0][:src] rescue nil
		puts images = [images]
		puts images = ::Htmlarticle.download_images(images) 
		category = "人工智能技术、无人系统、平台技术、网络与信息技术、电子科学技术、量子技术、光学技术、动力能源技术、新材料与新工艺"
		task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: author, con_time: ts, con_text: desp,attached_img_info: images, attached_media_info: attached_media_info, category: category}
		Rails.logger.info task
		puts task.to_json
		info = ::TData.save_one(task)
    	return info
	end
end