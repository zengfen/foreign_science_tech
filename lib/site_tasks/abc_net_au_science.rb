class AbcNetAuScience
  def initialize
    #RestClient.proxy = "http://192.168.50.1:1080/"
    @site = "abc广播新闻科学频道"
  end

  def list(body)
    tasks = []
    lk = "https://www.abc.net.au/news/science/"

    str = RestClient.get(lk).body
    doc = Nokogiri::HTML(str)
    doc.search("article .view-textlink").each do |item|
      p link = "https://www.abc.net.au" + item.search("a")[0][:href] rescue nil
      body = {link:link}
      puts body.to_json
      tasks << {mode:"item",body:URI.encode(body.to_json)}
      # tasks << {mode:"item",body:body}
    end
    return tasks
  end

  def item(body)
    body = JSON.parse(URI.decode(body))
    puts link = body["link"]
    res = RestClient.get(link).body
    doc = Nokogiri::HTML(res)
    title = doc.search("h1.title-padding-top-small")[0].inner_text.strip rescue nil

    p authors = doc.search('header span[data-component="Byline"] a').collect{|x| x.inner_text.strip}
    # authors << JSON.parse(doc.search('script[type="application/ld+json"]').inner_text)["author"]["name"]
    ts = doc.search('meta[property="article:published_time"]')[0][:content]
    puts ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")

    image_urls = []
    doc.search('figure img[data-component="Image"]').each do |one|
      next if one.to_s.match("base64")
      image_urls << one[:src].gsub(/\?.+?$/,"")
    end
    p image_urls
    images = ::Htmlarticle.download_images(image_urls)
    # p za = doc.search("aside")[-1].to_s
    # docc = Nokogiri::HTML(res.to_s.gsub("#{za}",""))
    # p desp = docc.search("#body").search("p,h2,li").collect{|x| x.inner_text.strip}.join("\n")
    params = {doc:doc,content_selector:"#body",html_replacer:"p||||li||||h2",content_rid_html_selector:"aside"}
    desp,_ = ::Htmlarticle.get_html_content(params)

    # html_content = doc.search("div.cmn-article_text").search("p,div").to_s
    files = []
    category = "新闻综合"
    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category}
    # puts task.to_json
    info = ::TData.save_one(task)
    return info
  end
end
