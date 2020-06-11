OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ssl_version] = 'TLSv1_2'
OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers] += ':DES-CBC3-SHA'
class PcmagazineCoIl
	def initialize
		@site = "电脑杂志"
		@prefix = "http://www.pcmagazine.co.il"
		@headers = {
			"user-agent" => "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.86 Safari/537.36"
		}
		# RestClient.proxy = "http://192.168.112.1:1080/"
	end
	def list(body)
		tasks = []
		if body.blank?
			urls = ["http://www.pcmagazine.co.il/category/mainpage"]
			urls.each do |url|
				puts body = {url:url}
				# tasks << {mode:"list",body:body}
				tasks << {mode:"list",body:URI.encode(body.to_json)}
			end
		else
			body = JSON.parse(URI.decode(body))
			# body = JSON.parse(body)
			url = body["url"]
			res = RestClient.get(url,@headers).body
			doc = Nokogiri::HTML(res)
			doc.search("div.catbRight div#inCat").each do |one|
				puts link = one.search("div.catItemTitle a")[0]["href"]
				puts link = @prefix + link if !link.match(/^http/)
				tss = one.search("div.catItemTitle span.catItemDate").inner_text
				t1 = tss.to_s.match(/(.+?)\//)[1]
				t2 = tss.to_s.match(/\/(.+?)$/)[1]
	       		t3 = t2.to_s.match(/(.+?)\//)[1]
	         	t4 = t2.to_s.match(/#{t3}\/(.+?)$/)[1]
          		ts = "20#{t4}/#{t3}/#{t1}"
			    time = Time.parse(ts).to_s rescue nil
				if link.include? "pcmagazine"
					body = {link:link,time:time}
					tasks << {mode:"item",body:URI.encode(body.to_json)}
				end
			end
		end
		return tasks
	end
	def item(body)
		body = JSON.parse(URI.decode(body))
		puts link = URI.encode(body["link"])
		headers = @headers
		# link = "http://www.pcmagazine.co.il/security/pid=7857&name=37-%D7%9E%D7%9C%D7%99%D7%95%D7%9F-%D7%9E%D7%A9%D7%AA%D7%9E%D7%A9%D7%99-%D7%90%D7%A9%D7%9C%D7%99-%D7%9E%D7%93%D7%99%D7%A1%D7%95%D7%9F-%D7%A0%D7%97%D7%A9%D7%A4%D7%99%D7%9D"
		res = RestClient.get(link,headers).body
		doc = Nokogiri::HTML(res)
		puts title = doc.search("div#ArticleId h1").inner_text.strip
		puts time = body["time"]
	    # time = Time.parse(tss).to_s rescue nil
	    # tt = Time.parse(time).to_i rescue nil
	    # puts ts = Time.at(tt) rescue nil
		author = []
		au = doc.search("div#articleBar a").inner_text rescue ""
		doc.search("div#articleBar a").each do |au|
			au = au.inner_text.strip
			author << au if au != ""
		end
		if au == ""
			as = doc.search("div#articleBar span").to_s.match(/\>(.+?)\<br/)[1] rescue ""
			as = "" if as.to_s.match("<a")
			author << as if as != ""
		end

		puts author = author.compact.uniq
		puts desp = doc.search("div.article").search("p").collect{|x| x.inner_text.strip}.join("\n")
		attached_media_info = []
		images = []
		doc.search("div.article img").each do |src|
			img = src[:src]
			images << img
		end
		puts images = ::Htmlarticle.download_images(images) 
		category = "人工智能技术、无人系统、平台技术、网络与信息技术、电子科学技术"
		task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: author, con_time: time, con_text: desp,attached_img_info: images, attached_media_info: attached_media_info, category: category}
		Rails.logger.info task
		puts task.to_json
		info = ::TData.save_one(task)
    	return info
	end
end