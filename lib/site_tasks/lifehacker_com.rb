class LifehackerCom
	def initialize
		@site = "lifehacker"
		@prefix = "https://lifehacker.com"
		# RestClient.proxy = "http://10.119.12.2:1076/"
	end
	def list(body)
		tasks = []
		if body.blank?
			urls = ["https://lifehacker.com/c/tech-911"]
			urls.each do |url|
				body = {url:url}
				tasks << {mode:"list",body:URI.encode(body.to_json)}
			end
		else
			body = JSON.parse(URI.decode(body))
			url = body["url"]
			i = 0
			res = RestClient::Request.execute(method: :get,url:url,verify_ssl: false)
			doc = Nokogiri::HTML(res.body)
			doc.search("div.dFCKPx div.aoiLP a").each do |one|
				puts url = one["href"]
				body = {url:url}
				tasks << {mode:"item",body:URI.encode(body.to_json)}
			end
		end
		return tasks
	end
	def item(body)
		body = JSON.parse(URI.decode(body))
		Rails.logger.info link = body["url"]
		res = RestClient.get(link)
		doc = Nokogiri::HTML(res.body)
		Rails.logger.info title = doc.search("div.gyRthi h1").inner_text.strip
		author = []
		author << doc.search("div.gclRUW a.js_link").inner_text.strip
		Rails.logger.info author
		Rails.logger.info time = Time.parse(doc.search("div.gfVGpi time")[0]["datetime"].to_s) rescue nil
		images = []
		doc.search("div.image-hydration-wrapper img").each do |img|
			url = img["data-srcset"].to_s.split(", ").last.gsub(" 800w","").gsub(" 1600w","")
			images << url
		end
		Rails.logger.info images = ::Htmlarticle.download_images(images.compact.uniq)
		params = {doc:doc,content_selector:"div.js_post-content",html_replacer:"p||||h3",content_rid_html_selector:"figcaption.no-caption,span.gTDhWp,div.bgZqzh,p em small"}
		desp,_ = ::Htmlarticle.get_html_content(params)
		Rails.logger.info desp
		category = "电子科技、人工智能、信息通讯"
		task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: author, con_time: time, con_text: desp,attached_img_info: images,category: category}
		Rails.logger.info task
		info = ::TData.save_one(task)
    	return info
	end
end