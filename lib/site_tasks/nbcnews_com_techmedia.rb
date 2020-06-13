class NbcnewsComTechmedia
  def initialize
   # RestClient.proxy = "http://192.168.50.1:1080/"
    @site = "nbc新闻科技与媒体频道"
  end
  def list(body)
    tasks = []
    lk = "https://www.nbcnews.com/tech-media"

    str = RestClient2.get(lk).body
    puts doc = Nokogiri::HTML(str)
    doc.search("h2 a").each do |item|
      link = item[:href] rescue nil
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
   # link = "https://www.nbcnews.com/tech/social-media/klamath-falls-oregon-victory-declared-over-antifa-which-never-showed-n1226681"
    res = RestClient2.get(link).body
    doc = Nokogiri::HTML(res)
    p title = doc.search("h1.article-hero__headline")[0].inner_text.strip rescue nil
    return if title == nil
    # authors << JSON.parse(doc.search('script[type="application/ld+json"]').inner_text)["author"]["name"]
    ts = doc.search("time")[0][:datetime]
    puts ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")
    puts "*"*100
    str = res.match(/window\.__data=(.+?)\}\}\;/)[1]+"\}\}"
    docc = JSON.parse(str.gsub("undefined","\"\"").gsub(/\"js\"\:.+?\}\,/,""))
    image_urls = []
    desp = []
    video = []
    authors = []
    docc["article"]["content"].each do |one|
      if one.to_s.match("primaryImage")
        image_urls<< one["primaryImage"]["url"]["primary"] rescue ""
      end
      if one.to_s.match("embeddedPerson")
        one["authors"].each do |au|
          authors << au["person"]["name"]
        end
      end
      if one.to_s.match("body")
        one["body"].each do |item|
          if item.to_s.match("html")
            desp << item["html"].to_s.gsub(/(?imx)<script.+?script>/,"").gsub(/(?imx)<style(.+?)style>/,"").gsub(/(?imx)<(\S*?)[^>]*>.*?|<.*? \/>/,"")
          elsif item.to_s.match("embeddedImage")
            image_urls << item["image"]["url"]["primary"]
          elsif item.to_s.match("videoAssets")
            vide_json = item["video"]["videoAssets"][0]
            url = vide_json["publicUrl"] +"&format=redirect&manifest=m3u&format=redirect&Tracking=true&Embedded=true&formats=MPEG4"
            video << RestClient2.get(url).to_s.match(/http.+?m3u8/)[0]
          end
        end
      end
    end
    p image_urls = image_urls - [""]
    p images = ::Htmlarticle.download_images(image_urls)
   desp = desp.join("\n")
    p attached_media_info = ::Htmlarticle.download_m3u8(video)
    files = []
    category = "人工智能技术、无人系统、平台技术、网络与信息技术、电子科学技术、生物及交叉技术"

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info:attached_media_info}
    # puts task.to_json
    info = ::TData.save_one(task)
    return info
  end

end
