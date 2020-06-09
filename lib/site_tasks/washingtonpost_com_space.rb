class WashingtonpostComSpace

  def initialize
    @site = "华盛顿邮报-科技-space"
  end

  def list(body)
    tasks = []
    if body.blank?
      urls = ["https://www.washingtonpost.com/space/?itid=nb_hp_technology_space"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      str = RestClient.get(url).body
      doc = Nokogiri::HTML(str)
      doc.search("section#main-content div.story-headline>h2>a").each do |item|
        link = item["href"] rescue nil
        next if link.blank?
        link = @prefix + link if !link.match(/^http/)
        body = {link:link}
        tasks << {mode:"item",body:URI.encode(body.to_json)}
      end
    end
    return tasks
  end

  def item(body)
    body = JSON.parse(URI.decode(body))
    puts link = body["link"]
    res = RestClient.get(link).body
    doc = Nokogiri::HTML(res)
    title = doc.search("header h1").inner_text.strip rescue nil
    if title.blank?
      title = doc.search("h1.title").inner_text.strip rescue nil
    end

    authors = []
    authors = doc.search("div.author-names").search("a>span.author-name").map { |e| e.inner_text.strip }

    # 页面时间显示有问题:页面刷新后时区变化
    ts = doc.search('article div.display-date').inner_text rescue nil
    ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")
    # puts time = Time.parse(ts).to_s rescue nil
    # tt = Time.parse(time).to_i rescue nil
    # puts Time.at(tt)
    # ts = Time.at(tt).strftime("%Y-%m-%d %H:%M:%S") rescue nil
    # ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")

    media = []
    image_urls = []
    media_url = []
    puts image = doc.search('meta[property="og:image"]')[0][:content] rescue nil
    if image != nil
      image_urls << image
    end
    # image_urls = doc.search("figure img").map{|x| puts x["src"]} rescue nil
    # image_urls = image_urls.uniq
    # images = ::Htmlarticle.download_images(image_urls)

    if doc.search("figure div.powa-skip").to_s.match("uuid")
      id1 = doc.search("figure div.powa-skip").to_s.match(/uuid\=\"(.+?)\"/)[1]
      id2 = id1.to_s.gsub("-","")
      ur = "https://video-api.washingtonpost.com/api/v1/ansvideos/findByUuid?uuid=#{id1}&cb=powaCallback#{id2}"
      st = RestClient.get(ur).body
      stt = st.to_s.match(/\((.+?)\)\;/)[1]
      docc = JSON.parse(stt)
      media_url << docc[0]["streams"][-1]["url"]
    end
    media = ::Htmlarticle.download_medias(media_url) rescue nil
    images = ::Htmlarticle.download_images(image_urls) rescue nil

    desp = doc.search("div.article-body").search("p,h2,li.pb-xs>span").collect{|x| x.inner_text.strip }.join("\n")
    files = []
    category = "人工智能技术、无人系统、平台技术、网络与信息技术、电子科学技术、量子技术、光学技术、动力能源技术、新材料与新工艺、"

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info: media}
    puts task.to_json

    info = ::TData.save_one(task)
    return info
  end
end
