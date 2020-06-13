class YomiuriCoJp

  def initialize
    @site = "读卖新闻-技术"
    @prefix = "https://www.yomiuri.co.jp"
  end

  def list(body)
    tasks = []
    if body.blank?
      urls = ["https://www.yomiuri.co.jp/science/"]
      urls.each do |url|
        body = {url:url}
        puts body.to_json
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
      # for i in 1..10
      #   url = "https://www.yomiuri.co.jp/y_ajax/latest_list/category/1562/1/1/20/#{i}/?action=latest_list&others=category%2F1562%2F1%2F1%2F20%2F#{i}%2F"
      #   body = {url:url}
      #   tasks << {mode:"list",body:URI.encode(body.to_json)}
      # end
    else
      # body = JSON.parse(URI.decode(body))
      # puts url = body["url"]
      # str = RestClient.get(url).body
      # jres = JSON.parse(str)["contents"]
      # doc = Nokogiri::HTML(jres)
      # doc.search("article div.p-list-item__inner").each do |item|
      #   link = item.search("h3>a")[0]["href"]
      #   member = item.search("div.c-list-member-only").inner_text.strip
      #   if !link.blank? && !member.include?("会員限定")
      #     link = @prefix + link if !link.match(/^http/)
      #     body = {link:link}
      #     tasks << {mode:"item",body:URI.encode(body.to_json)}
      #   end
      # end
      body = JSON.parse(URI.decode(body))
      puts url = body["url"]
      str = RestClient2.get(url).body
      doc = Nokogiri::HTML(str)
      doc.search("ul.p-category-organization-sec-list li,ul.p-category-time-series-sec-list li").each do |item|
        link = item.search("h3>a")[0]["href"] rescue nil
        member = item.search("div.c-list-member-only").inner_text.strip
        if !link.blank? && !member.include?("会員限定")
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
    res = RestClient2.get(link).body
    doc = Nokogiri::HTML(res)
    title = doc.search("h1.title-article")[0].inner_text.strip rescue nil

    authors = []
    ts = doc.search("time").inner_text.gsub(/\//,"-")
    ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")

    # []
    image_urls = doc.search("figure.wp-figure>a").map{|x| @prefix + x[:href]} rescue nil
    if image_urls.blank?
      image_urls = doc.search("figure.wp-caption>a").map{|x|
        next if x[:href].blank?
        @prefix + x[:href]
      } rescue nil
    end
    if !image_urls.blank?
      image_urls = image_urls.uniq
    end
    images = ::Htmlarticle.download_images(image_urls)

    desp = doc.search("div.p-main-contents").search("p").collect{|x| x.inner_text.strip }.join("\n").gsub("(ここから先は読者会員のみ見られます。こちらでログイン・会員登録をお願いします)","")

    files = []
    category = "新闻综合"

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category}


    info = ::TData.save_one(task)
    return info
  end
end
