class TimeComScience

  def initialize
    @site = "TIME-科学类"
    @prefix = "https://time.com"
    @header = {
      "Accept": "application/json;pk=BCpkADawqM0o-V-C4Z1AjOWaDFoPHhRNu7wcR4zltUdJva5oAiic0atdA0ax1Uts9bWapryRm9mEXAMSnnoWXzp_LmZkafu2INGTCCMDagSB-1MfOcm8Jr63X27l_uXDciHVfirybCvk4Ex0",
      "Accept-Encoding": "gzip, deflate, br",
      "Accept-Language": "zh-CN,zh;q=0.9,zh-TW;q=0.8,en-US;q=0.7,en;q=0.6",
      "Cache-Control": "no-cache",
      "Host": "edge.api.brightcove.com",
      "Connection": "keep-alive",
      "Origin": "https://time.com",
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36"
    }
  end

  def list(body)
    tasks = []
    if body.blank?
      urls = ["https://time.com/section/science/"]
      # urls = ["https://time.com/section/science/?page=1",
      #         "https://time.com/section/science/?page=2",
      #         "https://time.com/section/science/?page=3",
      #         "https://time.com/section/science/?page=4",
      #         "https://time.com/section/science/?page=5"]
      urls.each do |url|
        body = {url:url}
        puts body.to_json
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      str = RestClient.get(url).body
      doc = Nokogiri::HTML(str)
      doc.search("h3>a").each do |item|
        link = item["href"] rescue nil
        next if link.blank?
        link = @prefix + link if !link.match(/^http/)
        body = {link:link}
        puts body.to_json
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
    title = doc.search("h1.headline")[0].inner_text.strip rescue nil

    authors = []
    authors_temp = doc.search("a.author-name")[0].inner_text.strip rescue nil
    if !authors_temp.blank? && authors_temp.include?("/ AP")
      authors_temp = authors_temp.gsub(/\ \/\ AP/,"")
    end
    authors << authors_temp

    ts = doc.search("div.published-date").inner_text.strip rescue nil
    if ts.blank?
      ts = doc.search("script").to_s.match(/datePublished":"(.*?)\"\,\"dateModified/)[1]
    end
    if ts == ""
      return
    end
    ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")

    # []
    image_urls = doc.search("div.image-and-burst div.lead-media").map{|x| x["data-src"]} rescue nil
    images = ::Htmlarticle.download_images(image_urls)
    doc.search("p.author-feedback-text").remove
    desp = doc.search("div#article-body div.padded p,div#article-body div.padded>h2,div#article-body div.padded>h3").collect{|x| x.inner_text.strip }.join("\n")

    files = []
    category = "新闻综合"
    media = []
    media_url = []
    doc.search('video').each do |item|
      data_account = item["data-account"]
      videoId = item["data-video-id"]
      m_url = "https://edge.api.brightcove.com/playback/v1/accounts/" + "#{data_account}" + "/videos/" + "#{videoId}"
      str = RestClient.get(m_url,@header).body
      mdoc = JSON.parse(str)
      media_url << mdoc["sources"][4]["src"]
    end
    media = ::Htmlarticle.download_medias(media_url)
    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info: media}


    info = ::TData.save_one(task)
    return info
  end
end
