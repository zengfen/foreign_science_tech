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

      headers = {
        "Host": "www.iaf.org.il",
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
        "Sec-Fetch-Site": "none"
        "Sec-Fetch-Mode": "navigate",
        "Sec-Fetch-User": "?1",
        "Sec-Fetch-Dest": "document",
        "Accept-Encoding": "deflate",
        "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,zh-TW;q=0.7,ja;q=0.6,mt;q=0.5",
        #Cookie: ASP.NET_SessionId=bbx3nmi3dz2xfkli1qpwfgt2; TS01262670=010f83961dc48a62a9fb5786b91fca5b20f4c9d3aefba19e4ef735cf30d80299f427c21e536ccd39e649008d1d926becc2d357dd722284aa9ce201727951d8f935e653eaad; _ga=GA1.3.1149211527.1591615818; _gid=GA1.3.1446511440.1591615818; __atuvc=1%7C24; __atuvs=5ede21764e3b8a0c000
      }
      body = JSON.parse(URI.decode(body))
      puts url = body["url"]
      res = RestClient.get(url,headers=headers)
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
