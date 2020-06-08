class IafOrgIl
	def initialize
		@site = "以色列空军杂志-技术"
    	@prefix = "https://www.iaf.org.il"
    	# RestClient.proxy = "http://192.168.235.1:1080/"
	end

	def list(body)
    	tasks = []
    	if body.blank?
      		urls = ["https://www.iaf.org.il/Templates/Shared/UserControls/Header/7229-he/IAF.aspx"]
     		urls.each do |url|	
        		body = {url:url}
       			tasks << {mode:"list",body:URI.encode(body.to_json)}
       			# tasks << {mode:"list",body:body}
      		end
    	else
    		body = JSON.parse(URI.decode(body))
      		url = body["url"]
      		res = RestClient.get(url)
      		doc = Nokogiri::HTML(res.body)
      		doc.search("div.grad_grey.link-wrapper").each_with_index do |item|
        		link = item["onmouseover"].gsub("window.status='","").gsub("'","") rescue nil
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
   	 	res = RestClient.get(link).body
    	doc = Nokogiri::HTML(res)
    	#获取标题	
    	title = doc.search("h1.inner_page_header").inner_html.strip rescue nil
    	puts "标题"
    	puts title
    	#获取正文
    	params = {doc:doc,content_selector:"span.full_list_link.h2_content_text||||div.inner_bit_page_text_holder",html_replacer:"h2||||h3||||div.line",content_rid_html_selector:""}
    	desp,html_content = ::Htmlarticle.get_html_content(params)
    	puts "正文"
    	puts desp

    	# 获取图片
    	image_urls = doc.search("div.inner_bit_page_pic_holder img").map { |x| x["src"].match(/^http/) ? x["src"] : @prefix + x["src"] } rescue nil
    	puts "图片链接"
    	puts image_urls
    	images = ::Htmlarticle.download_images(image_urls)


    	task = {data_address:link,website_name:@site,data_spidername:self.class,data_snapshot_path:html_content,con_title:title,con_text:desp,attached_img_info: images}
    	puts "====item==task==#{task}"

    	info = ::TData.save_one(task)
    	return info
	end
end