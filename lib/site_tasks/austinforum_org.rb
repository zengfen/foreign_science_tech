class AustinforumOrg
	def initialize
		@site = "austin forum"
    	@prefix = "https://www.austinforum.org"
	end

	def list(body)
		RestClient.proxy = "http://192.168.235.1:1080/"
		tasks = []
    	if body.blank?
      		urls = ["https://www.austinforum.org/news"]
     		urls.each do |url|	
        		body = {url:url}
       			# tasks << {mode:"list",body:URI.encode(body.to_json)}
       			tasks << {mode:"list",body:body}
      		end
    	else
    		# body = JSON.parse(URI.decode(body))
      		url = body["url"]
      		res = RestClient.get(url)
      		doc = Nokogiri::HTML(res.body)
      		doc.search("h2.blog-title a.blog-title-link.blog-link").each_with_index do |item,index|
        		link = item["href"].gsub("//","") rescue nil
        		puts "链接"
        		puts link
        		body = {link:link}
        		# tasks << {mode:"item",body:URI.encode(body.to_json)}
        		tasks << {mode:"item",body:body}
      		end
      	end
    	return tasks
	end

	def item(body)
		# body = JSON.parse(URI.decode(body))
  		link = body["link"]
   	 	res = RestClient.get(link).body
    	doc = Nokogiri::HTML(res)
    	#获取标题	
    	title = doc.search("h2.blog-title a").inner_html.strip rescue nil
    	puts "标题"
    	puts title
    	#获取正文
    	params = {doc:doc,content_selector:"div.paragraph",html_replacer:"br",content_rid_html_selector:""}
    	desp,html_content = ::Htmlarticle.get_html_content(params)
    	puts "正文"
    	puts desp
    	#获取时间
    	ts = Time.parse(doc.search("p.blog-date span.date-text").inner_html.strip).to_s
    	puts "时间"
    	puts ts
    	#获取作者


    	task = {data_address:link,website_name:@site,data_spidername:self.class,data_snapshot_path:html_content,con_title:title, con_time:ts, con_text:desp}
    	puts "====item==task==#{task}"

    	info = ::TData.save_one(task)
    	return info
	end
end