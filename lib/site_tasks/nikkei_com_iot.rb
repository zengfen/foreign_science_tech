class NikkeiComIot

  def initialize
    # RestClient.proxy = "http://192.168.50.1:1080/"
    @site = "日本经济报-技术-物联网"
    @prefix = "https://www.nikkei.com"
  end

  def list(body)
    tasks = []
      lk = "https://www.nikkei.com/technology/iot/"

      str = RestClient.get(lk).body
      doc = Nokogiri::HTML(str)
      doc.search("h3.m-miM09_title").each do |item|
        next if item.to_s.match("有料会員限定")
        link = item.search("a")[0][:href] rescue nil
        next if link.blank?
        link = @prefix + link if !link.match(/^http/)
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
    puts res = RestClient.get(link).body
    doc = Nokogiri::HTML(res)
    title = doc.search("h1.cmn-article_title")[0].inner_text.strip rescue nil

    authors = []
    # authors << JSON.parse(doc.search('script[type="application/ld+json"]').inner_text)["author"]["name"]
    ts = doc.search("dd.cmnc-publish").inner_text.gsub(/\//,"-")
    puts ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")

    # []
    p image_urls = doc.search('div.cmnc-figure img,div[style="cmnc-figure"] img').map{|x| x[:src]} rescue nil
    images = ::Htmlarticle.download_images(image_urls)

    p desp = doc.search("div.cmn-article_text").search("p").collect{|x| x.inner_text.strip}.join("\n")
    # html_content = doc.search("div.cmn-article_text").search("p,div").to_s

    files = []
    category = "人工智能技术、无人系统、平台技术、网络与信息技术、电子科学技术、动力能源技术、新材料与新工艺"

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category}

    info = ::TData.save_one(task)
    return info
  end
end
