class LemondeFr
  def initialize
    @site = "france lemonde-science"
    @prefix = "https://www.lemonde.fr/sciences/"
    # RestClient.proxy = "http://192.168.16.1:1080/"
  end

  def list(body)

    tasks = []
    if body.blank?
      urls = ["https://www.lemonde.fr/sciences/"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      res = RestClient.get(url)
      doc = Nokogiri::HTML(res.body)
      doc.search("a.teaser__link").each_with_index do |item,index|
        link = item["href"] rescue nil
        # link ="https://www.reuters.com/article" + link if !link.match(/^http/)
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
    # link = "https://www.lemonde.fr/culture/article/2020/05/24/inegalites-salariales-genetique-guerre-de-coree-quatre-documentaires-pour-s-immerger-en-replay_6040566_3246.html"
    res = RestClient.get(link).body
    doc = Nokogiri::HTML(res)

    if doc.to_s.match("article__header")
      puts title = doc.search("h1.article__title")[0].inner_text.strip rescue nil
    elsif doc.to_s.match("article__heading")
      puts title = doc.search("h1.article__title")[0].inner_text.strip rescue nil
    elsif doc.to_s.match("entry-header")
      puts title = doc.search("h1.entry-title")[0].inner_text.strip rescue nil
    elsif doc.to_s.match("js-title-live")
      puts title = doc.search("h1#js-title-live")[0].inner_text.strip rescue nil
    end

    if doc.to_s.match("og:article:published_time")
      timepublished = doc.search("meta[property='og:article:published_time']")[0]["content"]
      ts = Time.parse(timepublished).strftime("%Y-%m-%d %H:%M:%S") rescue nil
    else
      timepublished = doc.search("meta[property='article:published_time']")[0]["content"]
      ts = Time.parse(timepublished).strftime("%Y-%m-%d %H:%M:%S") rescue nil
    end

    if doc.to_s.match("article__content")
      params = {doc:doc,content_selector:"section.article__wrapper>article.article__content||||section.article__content",html_replacer:"h2||||p",content_rid_html_selector:"figure||||section"}
      desp,_ = ::Htmlarticle.get_html_content(params)
    elsif doc.to_s.match("entry-content")
      params = {doc:doc,content_selector:"div.entry-content",html_replacer:"p",content_rid_html_selector:"p>a||||p>strong"}
      desp,_ = ::Htmlarticle.get_html_content(params)
    elsif doc.to_s.match("js-facts-live")
      params = {doc:doc,content_selector:"section#js-facts-live",html_replacer:"h2||||ul",content_rid_html_selector:""}
      desp,_ = ::Htmlarticle.get_html_content(params)
    end


    image_urls = []
    if doc.to_s.match("twitter:image")
      image_urls << doc.search("meta[property='twitter:image']")[0]["content"].to_s
      images = ::Htmlarticle.download_images(image_urls)
    else
      doc.search("div.entry-content p a img").each do |img|
        image_urls << img[:src]
      end
      images = ::Htmlarticle.download_images(image_urls)
    end

    media_urls = []
    if doc.to_s.match("og:video")
      src =  doc.search("meta[property='og:video']")[0]["content"]
      video_id = src.to_s.split("embed/")[1].split("?")[0]
      request_url = "https://www.youtube.com/get_video_info?video_id=#{video_id.to_s}"
      request_res = RestClient.get(request_url)
      urires = URI.decode(request_res.to_s)
      # Rails.logger.info uriressplit = urires.split('"url":"')[1].split('","mimeType"')[0]
      # jsonres = JSON.parse(uriressplit)
      video_url = urires.split('"url":"')[1].split('","mimeType"')[0]
      viurl = URI.decode(URI.decode(video_url)).gsub('\u0026',"&")
      media_urls << viurl
    end
    medias = ::Htmlarticle.download_medias(media_urls)
    category = "人工智能技术、无人系统、平台技术、网络与信息技术、电子科学技术、量子技术、光学技术、动力能源技术、新材料与新工艺、生物及交叉技术、海洋科学技术、"
    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_time: ts, con_text: desp,attached_img_info: images,category: category,attached_media_info:medias}
    puts task.to_json
    #  "====item==task==#{task}"
    info = ::TData.save_one(task)
    return info
  end

end
