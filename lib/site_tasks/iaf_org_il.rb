require 'rss'
class IafOrgIl
	def initialize
		@site = "以色列空军杂志-技术"
    	@prefix = "https://www.iaf.org.il"
    	# RestClient.proxy = "http://192.168.235.1:1080/"
	end

	def list(body)
    	tasks = []
    	if body.blank?
      		urls = ["https://www.iaf.org.il/9202-en/IAF.aspx"]
     		  urls.each do |url|	
        		body = {url:url}
        			tasks << {mode:"list",body:URI.encode(body.to_json)}
       			# tasks << {mode:"list",body:body}
      		end
    	else
    		body = JSON.parse(URI.decode(body))
      		url = body["url"]
          res = RestClient2.get(url).body
          doc = Nokogiri::XML(res, nil, 'utf-8')
          doc.search("a.cards-container__card-link").each do |item|
        		link = item[:href]
        		puts "链接"
        		puts link 
        		body = {link:link}
        		tasks << {mode:"item",body:URI.encode(body.to_json)}
        		# tasks << {mode:"item",body:body}
      		end
      end
    	return tasks
	end

	def item(body)
		body = JSON.parse(URI.decode(body))
  		link = body["link"]
   	 	res = RestClient2.get(link).body
    	doc = Nokogiri::HTML(res)
    	#获取标题	
    	title = doc.search("h1.titleHeader").inner_html.strip rescue nil
    	puts "标题"
    	puts title

    	#获取正文
    	params = {doc:doc,content_selector:"div.container,div.innerBox p",html_replacer:"strong||||p",content_rid_html_selector:""}
    	desp,html_content = ::Htmlarticle.get_html_content(params)
    	puts "正文"
    	puts desp

    	# 获取图片
    	# image_urls = doc.search("img.oneImg").map { |x| x["src"].match(/^http/) ? x["src"] : @prefix + x["src"] } rescue nil
      image_urls = []
      doc.search("div.innerBox img").each do |img|
        if img[:src].to_s.include?"http://www.iaf.org.il"
          image_urls << img[:src].to_s
        else
          image_urls << "http://www.iaf.org.il"+img[:src].to_s
        end
      end
    	puts "图片链接"
    	puts image_urls
    	images = ::Htmlarticle.download_images(image_urls)

    	#获取时间
    	ts = Time.parse(doc.search("div.titleText span#ctl00_ContentPlaceHolder1_ucEventLog_publishDate")) rescue nil
    	puts "时间"
    	puts ts

      category = "武器与毁伤防护技术"
    	task = {data_address:link,website_name:@site,category:category, data_spidername:self.class,data_snapshot_path:html_content,con_title:title,con_time: ts,con_text:desp,attached_img_info: images}
    	puts "====item==task==#{task}"

    	info = ::TData.save_one(task)
    	return info
	end
end