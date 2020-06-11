class NewsBoxunCom

  def initialize
    @site = "博讯新闻-财经科技"
    @prefix = "https://news.boxun.com"
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
        puts body.to_json
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      str = RestClient.get(url).body
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
    res = RestClient.get(link).body
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

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info: media}
    puts task.to_json

    info = ::TData.save_one(task)
    return info
  end
end
