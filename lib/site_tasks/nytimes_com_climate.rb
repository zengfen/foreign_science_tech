class NytimesComClimate
	def initialize
		@site = "纽约时报-science-environment"
		@prefix = "https://www.nytimes.com"
		# RestClient.proxy = "http://192.168.0.101:1077/"
	end
	def list(body)
		tasks = []
		if body.blank?
			urls = ["https://www.nytimes.com/section/climate"]
			urls.each do |url|
				body = {url:url}
				tasks << {mode:"list",body:URI.encode(body.to_json)}
			end
		else
			body = JSON.parse(URI.decode(body))
			url = body["url"]
			res = RestClient.get(url)
			doc = Nokogiri::HTML(res.body)
			doc.search("ol.ekkqrpp2 li.ekkqrpp3 h2 a,div.css-13mho3u li.css-ye6x8s a").each do |one|
				link = one["href"]
				link = @prefix + link if !link.match(/^http/)
				body = {link:link}
				tasks << {mode:"item",body:URI.encode(body.to_json)}
			end
		end
		return tasks
	end
	# def list(body)
	# 	tasks = []
	# 	if body.blank?
	# 		urls = ["https://www.nytimes.com/section/climate"]
	# 		urls.each do |url|
	# 			body = {url:url}
	# 			tasks << {mode:"list",body:URI.encode(body.to_json)}
	# 		end
	# 	else
	# 		body = JSON.parse(URI.decode(body))
	# 		url = "https://samizdat-graphql.nytimes.com/graphql/v2"
	# 		data = {"operationName":"CollectionsQuery","variables":{"id":"/section/climate","first":10,"query":{"sort":"newest"},"exclusionMode":"HIGHLIGHTS_AND_EMBEDDED","highlightsListUri":"nyt://per/personalized-list/__null__","highlightsListFirst":0,"hasHighlightsList":false,"cursor":"YXJyYXljb25uZWN0aW9uOjk="},"extensions":{"persistedQuery":{"version":1,"sha256Hash":"93317fead69f16d9b0538ab12ea6caf2f5ed0cf5b539bdc00dced43e8c48f655"}}}
	# 		header = {
	# 			"authority"=> "samizdat-graphql.nytimes.com",
	# 			"method"=> "POST",
	# 			"path"=> "/graphql/v2",
	# 			"scheme"=> "https",
	# 			"accept"=> "*/*",
	# 			"accept-encoding"=> "gzip, deflate, br",
	# 			"accept-language"=> "zh-CN,zh;q=0.9",
	# 			"content-length"=> "424",
	# 			"content-type"=> "application/json",
	# 			"cookie"=> "nyt-a=TBix-XhvCSY9OvTqYfYdPs; __gads=ID=48a6147c16a4b186:T=1591262936:S=ALNI_MZQqXaNotb_5WXPnprQ4_Nf4ClRzA; _gcl_au=1.1.1202742066.1591262780; walley=GA1.2.664709617.1591262775; iter_id=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhaWQiOiI1ZWQ4YmVlYTRkMTE2OTAwMDExZGFiNDkiLCJjb21wYW55X2lkIjoiNWMwOThiM2QxNjU0YzEwMDAxMmM2OGY5IiwiaWF0IjoxNTkxMjYyOTU0fQ.t-glJGluFcDlH38c8wIBSd4-oUIwZVH_rYKipoe9Lfs; purr-cache=<K0<r<C_<G_<S0; nyt-gdpr=0; nyt-purr=cfshcfhssc; nyt-us=1; nyt-geo=US; b2b_cig_opt=%7B%22isCorpUser%22:false%7D; edu_cig_opt=%7B%22isEduUser%22:false%7D; walley_gid=GA1.2.883284566.1591587921; datadome=Ubeg8HzSHYp2khpK5lJopWpCCuUm57X-3ogRTz7PZbt6yLump4OloVupp75nDBrbNFIHEM9Nr152qNMjDthJ1p17rlBwTy7bUmrkj5y_hh; nyt-jkidd=uid=0&lastRequest=1591618812623&activeDays=%5B0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C1%2C1%2C0%2C0%2C1%5D&adv=3&a7dv=3&a14dv=3&a21dv=3&lastKnownType=anon; nyt-m=C602021CE5401ACBB15C8E145453BB9B&e=i.1593561600&cav=i.0&ica=i.0&igd=i.0&ird=i.0&ft=i.0&igf=i.0&prt=i.0&ira=i.0&l=l.1.2425477009&n=i.2&pr=l.4.0.0.0.0&imu=i.1&ier=i.0&iub=i.0&ifv=i.0&iir=i.0&g=i.0&iga=i.0&iru=i.0&rc=i.0&vp=i.0&fv=i.0&t=i.1&er=i.1591618936&igu=i.1&v=i.1&vr=l.4.0.0.0.0&iue=i.0&imv=i.0&s=s.core&uuid=s.1f0a571a-7af6-47bd-8e4d-215e01a840f1",
	# 			"nyt-app-type"=> "project-vi",
	# 			"nyt-app-version"=> "0.0.5",
	# 			"nyt-token"=> "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAs+/oUCTBmD/cLdmcecrnBMHiU/pxQCn2DDyaPKUOXxi4p0uUSZQzsuq1pJ1m5z1i0YGPd1U1OeGHAChWtqoxC7bFMCXcwnE1oyui9G1uobgpm1GdhtwkR7ta7akVTcsF8zxiXx7DNXIPd2nIJFH83rmkZueKrC4JVaNzjvD+Z03piLn5bHWU6+w+rA+kyJtGgZNTXKyPh6EC6o5N+rknNMG5+CdTq35p8f99WjFawSvYgP9V64kgckbTbtdJ6YhVP58TnuYgr12urtwnIqWP9KSJ1e5vmgf3tunMqWNm6+AnsqNj8mCLdCuc5cEB74CwUeQcP2HQQmbCddBy2y0mEwIDAQAB",
	# 			"origin"=> "https://www.nytimes.com",
	# 			"referer"=> "https://www.nytimes.com/section/climate",
	# 			"sec-fetch-dest"=> "empty",
	# 			"sec-fetch-mode"=> "cors",
	# 			"sec-fetch-site"=> "same-site",
	# 			"user-agent"=> "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36",
	# 		}
	# 		res = RestClient.post(url,data)
	# 		doc = Nokogiri::HTML(res.body)
	# 		doc.search("ol.ekkqrpp2 li.ekkqrpp3 h2 a,div.css-13mho3u li.css-ye6x8s a").each do |one|
	# 			link = one["href"]
	# 			link = @prefix + link if !link.match(/^http/)
	# 			body = {link:link}
	# 			tasks << {mode:"item",body:URI.encode(body.to_json)}
	# 		end
	# 	end
	# 	return tasks
	# end
	def item(body)
		body = JSON.parse(URI.decode(body))
		puts link = body["link"]
		# puts link = "https://venturebeat.com/2020/06/01/argo-closes-2-6-billion-round-from-vw-at-a-7-25-billion-valuation/"
		res = RestClient.get(link).body
		# res = RestClient::Request.execute(method: :get,url:link,verify_ssl: false).body
		doc = Nokogiri::HTML(res)
		Rails.logger.info title = doc.search("div.css-1vkm6nb h1,h1#interactive-heading,h1.story-heading").inner_text.strip
		ts = doc.search("meta[property='article:published']")[0]["content"].to_s rescue nil
		Rails.logger.info time = Time.parse(ts) rescue nil
		author = []
		author << doc.search("div.css-1baulvz span.last-byline,p#interactive-byline span.last-byline,p.byline-dateline span.byline-author").inner_text.strip
		Rails.logger.info author
		params = {doc:doc,content_selector:"section.meteredContent p.css-158dogj,div.g-story p.g-body,div.g-graphic p.g-body",html_replacer:"p",content_rid_html_selector:""}
		desp,_ = ::Htmlarticle.get_html_content(params)
		Rails.logger.info desp
		image_urls = []
		doc.search("figure.sizeLarge.layoutHorizontal,figure.css-jcw7oy.e1g7ppur0").each do |img|
			image_urls << img["itemid"]
		end
		Rails.logger.info image_urls
		images = ::Htmlarticle.download_images(image_urls)
		videos = []
		doc.search("figure video.cinemagraph_video").each do |video|
			videos << video["src"]
		end
		Rails.logger.info videos
		attached_media_infos = ::Htmlarticle.download_medias(videos)
		category = "生物及交叉技术、海洋科学技术"
		task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: author, con_time: time, con_text: desp,attached_img_info: images.compact.uniq, category: category,attached_media_infos: attached_media_infos}
		Rails.logger.info task
		info = ::TData.save_one(task)
    	return info
	end
end