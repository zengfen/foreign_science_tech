class IafOrgIl
  def initialize
    @site = "以色列空军杂志-技术"
    @prefix = "https://www.iaf.org.il"
    # RestClient.proxy = "http://192.168.235.1:1080/"
  end

  def list(body)
    tasks = []
    if body.blank?
      urls = ["https://www.iaf.org.il/9202-en/IAF.aspx"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:URI.encode(body.to_json)}
        # tasks << {mode:"list",body:body}
      end
    else

      body = JSON.parse(URI.decode(body))
      puts url = body["url"]
      res = RestClient.get(url)
      puts res.body
      doc = Nokogiri::HTML(res.body)
      doc.search("a.info-box__link,a.cards-container__card-link").each_with_index do |item|
        link = item["href"] rescue nil
        puts "链接"
        puts link
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
    res = RestClient.get(link).body
    doc = Nokogiri::HTML(res)
    #获取标题
    title = doc.search("h1.titleHeader").inner_html.strip rescue nil
    puts "标题"
    puts title

    #获取正文
    params = {doc:doc,content_selector:"div.innerBox strong,div.innerBox p",html_replacer:"strong||||p",content_rid_html_selector:""}
    desp,html_content = ::Htmlarticle.get_html_content(params)
    puts "正文"
    puts desp

    # 获取图片
    image_urls = doc.search("img.oneImg").map { |x| x["src"].match(/^http/) ? x["src"] : @prefix + x["src"] } rescue nil
    puts "图片链接"
    puts image_urls
    images = ::Htmlarticle.download_images(image_urls)

    #获取时间
    ts = Time.parse(doc.search("span.ctl00_ContentPlaceHolder1_ucEventLog_publishDate")) rescue nil
    puts "时间"
    puts ts

    task = {data_address:link,website_name:@site,data_spidername:self.class,data_snapshot_path:html_content,con_title:title,con_time: ts,con_text:desp,attached_img_info: images}
    puts "====item==task==#{task}"

    info = ::TData.save_one(task)
    return info
  end
end
