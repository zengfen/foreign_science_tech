class NewsBoxunCom

  def initialize
    @site = "博讯新闻-财经科技"
    @prefix = "https://news.boxun.com"
    @header = {
      "accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "cookie": "__cfduid=d88e3705cb0d40aabd841334d210389e21594966105; __gads=ID=4938c3ded9da7bbe:T=1594966106:S=ALNI_MYAE_NsIYXPUNk-ZKBo6JsgXTer3w; cf_clearance=be63c1c2c1c3fb8b57361bc11f4b9aca3e2f2c47-1596608416-0-1z9fcb4711zc0c6343cze9159676-150; __utma=204650115.1115848014.1596608475.1596608475.1596608475.1; __utmc=204650115; __utmz=204650115.1596608475.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)",
      "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36"
    }
  end

  def list(body)
    tasks = []
    if body.blank?
      # urls = ["https://news.boxun.com/news/gb/finance/page1.shtml",
      #         "https://news.boxun.com/news/gb/finance/page2.shtml",
      #         "https://news.boxun.com/news/gb/finance/page3.shtml",
      #         "https://news.boxun.com/news/gb/finance/page4.shtml",
      #         "https://news.boxun.com/news/gb/finance/page5.shtml",
      #         "https://news.boxun.com/news/gb/finance/page6.shtml",
      #         "https://news.boxun.com/news/gb/finance/page7.shtml",
      #         "https://news.boxun.com/news/gb/finance/page8.shtml",
      #         "https://news.boxun.com/news/gb/finance/page9.shtml",
      #         "https://news.boxun.com/news/gb/finance/page10.shtml"]
      urls = ["https://news.boxun.com/news/gb/finance/page1.shtml"]
      urls.each do |url|
        body = {url:url}
        # puts body.to_json
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      # str = RestClient.get(url,@header).force_encoding("windows-1252").encode("utf-8")
      str = RestClient2.get(url,@header)
      # puts str.to_s
      # Rails.logger.info(str.to_s)
      doc = Nokogiri::HTML(str)
      doc.search('a[href*="news\/gb\/finance\/"]').each do |item|
        link = item["href"] rescue nil
        # next if link.blank? && link.include?("finance/page")
        # puts !link.include?("finance/page")
        # puts link.blank?
        if !link.blank? && !link.include?("finance/page")
          link = @prefix + link if !link.match(/^http/)
          body = {link:link}
          tasks << {mode:"item",body:URI.encode(body.to_json)}
        end
      end
    end
    return tasks
  end

  def item(body)
    body = JSON.parse(URI.decode(body))
    puts link = body["link"]
    res = RestClient2.get(link,@header).body
    doc = Nokogiri::HTML(res)
    title_temp = doc.search(".F11 center")[0].inner_text.strip rescue nil
    zz = doc.search("center")[2].search("font").inner_text.strip rescue nil
    title = title_temp.gsub(zz,"").strip
    # title = doc.search(".F11 b")[0].inner_text.strip rescue nil
    authors = []
    ts = doc.search("center small")[0].inner_text.gsub(/博讯北京时间/,"").gsub(/年|月|日/,"-")
    ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")

    # []
    image_urls = doc.search('.F11 div[align="center"] img,.F11 img').map{|x|
      next if x[:src].blank?
      @prefix + x[:src] if !x[:src].match(/^http/)
    }
    image_urls = image_urls.uniq
    images = ::Htmlarticle.download_images(image_urls)
    # .F11 b,
    doc.search(".F11 script,.F11 noscript,.F11 tr td table,.F11 .dsq-brlink").remove
    doc.search(".F11 center")[0].remove
    desp = doc.search(".F11").collect{|x| x.inner_text.strip }.join("\n")
    media = []
    # media = doc.search(".F11 iframe").map { |e| e["src"] }
    # .to_s.gsub("BR","\n").to_s.inner_text.join("\n")
    files = []
    category = "新闻综合"
    puts res.encode!("utf-8", :undef => :replace, :replace => "?", :invalid => :replace)
    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info: media}
    # puts task.to_json
    info = ::TData.save_one(task)
    return info
  end
end
