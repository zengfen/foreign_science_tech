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
        # tasks << {mode:"list",body:body}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      str = RestClient.get(url).body
      doc = Nokogiri::HTML(str)
      doc.search("ul.p-category-organization-sec-list li,ul.p-category-time-series-sec-list li").each do |item|
        link = item.search("h3>a")[0]["href"] rescue nil
        member = item.search("div.c-list-member-only").inner_text.strip
        if !link.blank? && !member.include?("会員限定")
          link = @prefix + link if !link.match(/^http/)
          body = {link:link}
          # puts body.to_json
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
    title = doc.search("h1.title-article")[0].inner_text.strip rescue nil

    authors = []
    ts = doc.search("time").inner_text.gsub(/\//,"-")
    ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")

    # []
    image_urls = doc.search("figure.wp-figure a").map{|x| @prefix + x[:href]} rescue nil
    image_urls = image_urls.uniq
    images = ::Htmlarticle.download_images(image_urls)

    desp = doc.search("div.p-main-contents").search("p").collect{|x| x.inner_text.strip }.join("\n")

    files = []
    category = "新闻综合"

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category}
    puts task.to_json
    
    info = ::TData.save_one(task)
    return info
  end
end
