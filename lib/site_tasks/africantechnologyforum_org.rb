class AfricantechnologyforumOrg
  def initialize
		@site = "african technology  forum-news-ictechnology"
    	@prefix = "http://africantechnologyforum.org/"
	end

	def list(body)
		header = {
 "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
 "Accept-Encoding": "deflate",
 "Accept-Language": "zh-CN,zh;q=0.9",
 "Cache-Control": "max-age=0",
 "Cookie": "TS0194eee0=010bd7804481b3b4409bb028f69d52a08dd241c7058e7ec3d07a33b98e8af82e58b09e24a27a1bb42caba4c5320af31a704dffed55",
 "Host": "africantechnologyforum.org",
 "Proxy-Connection": "keep-alive",
 "Upgrade-Insecure-Requests": "1",
 "User-Agent": "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36"
}

		# RestClient.proxy = "http://192.168.235.1:1080/"
		tasks = []
    	if body.blank?
      		urls = ["http://africantechnologyforum.org/category/news/news-ictechnology/"]
     		urls.each do |url|
        		body = {url:url}
       			tasks << {mode:"list",body:URI.encode(body.to_json)}
      		end
    	else
    		body = JSON.parse(URI.decode(body))
      		url = body["url"]
      		res = RestClient.get(url,header = header)
      		doc = Nokogiri::HTML(res.body)
      		doc.search("div.td-module-thumb a").each_with_index do |item,index|
        		link = item["href"] rescue nil
        		puts link
        		body = {link:link}
        		tasks << {mode:"item",body:URI.encode(body.to_json)}
      		end
      	end
    	return tasks
	end

  	def item(body)
  		header = {
 "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
 "Accept-Encoding": "deflate",
 "Accept-Language": "zh-CN,zh;q=0.9",
 "Cache-Control": "max-age=0",
 "Cookie": "TS0194eee0=010bd7804481b3b4409bb028f69d52a08dd241c7058e7ec3d07a33b98e8af82e58b09e24a27a1bb42caba4c5320af31a704dffed55",
 "Host": "africantechnologyforum.org",
 "Proxy-Connection": "keep-alive",
 "Upgrade-Insecure-Requests": "1",
 "User-Agent": "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36"
}
		body = JSON.parse(URI.decode(body))
  		link = body["link"]
  		# link = "http://africantechnologyforum.org/shedalert-load-shedding-alerts/"
   	 	res = RestClient.get(link,header = header).body
    	doc = Nokogiri::HTML(res)
    	#获取标题
    	title = doc.search("h1.entry-title").inner_html.strip rescue nil
    	puts "标题"
    	puts title
    	#获取正文
    	params = {doc:doc,content_selector:"div.td-post-content",html_replacer:"p",content_rid_html_selector:""}
    	desp,html_content = ::Htmlarticle.get_html_content(params)
    	puts "正文"
    	puts desp
    	#获取时间
    	ts = Time.parse(doc.search("time.entry-date.updated.td-module-date")[0]["datetime"]).to_s
    	puts "时间"
    	puts ts
    	#获取作者
      authors = []
    	author = doc.search("div.td-post-author-name a").inner_text.strip.gsub(/^by /i,"") rescue nil
      authors << author
      authors = authors.uniq.compact
    	puts "作者"
    	puts authors

      category = "新闻综合"
    	task = {data_address:link,website_name:@site,category:category,data_spidername:self.class,data_snapshot_path:html_content,con_title:title, con_author:authors, con_time:ts, con_text:desp}
    	puts "====item==task==#{task}"

    	info = ::TData.save_one(task)
    	return info
  	end
end