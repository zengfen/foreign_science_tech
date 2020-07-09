class TorrentfreakCom
  def initialize
    @site = "TorrentFreak"
    @prefix = "https://torrentfreak.com/category/technology/"
    # RestClient.proxy = "http://192.168.16.1:1080/"
  end

  def list(body)
    tasks = []
    if body.blank?
      urls = ["https://torrentfreak.com/category/technology/"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:URI.encode(body.to_json)}
        # tasks << {mode:"list",body:body}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      res = RestClient2.get(url)
      doc = Nokogiri::HTML(res.body)
      doc.search("div.grid-equalHeight div.col-4_sm-6_xs-12 a").each_with_index do |item,index|
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
    # link = "https://torrentfreak.com/team-xecuter-accuses-nintendo-of-censorship-and-legal-scare-tactics-200611/"
    res = RestClient2.get(link).body
    doc = Nokogiri::HTML(res)
    title = doc.search("div.container div.hero__content h1.hero__title")[0].inner_text.strip rescue nil

    timepublished = doc.search("meta[property='article:published_time']")[0]["content"]
    ts = Time.parse(timepublished).strftime("%Y-%m-%d %H:%M:%S") rescue nil

    params = {doc:doc,content_selector:"section.page__content div.article__body",html_replacer:"p",content_rid_html_selector:"center"}
    desp,_ = ::Htmlarticle.get_html_content(params)
    desp

    img_urls = []
    doc.search("section.page__content div.article__body center img").each do |img|
      img_urls << img["src"]
    end
    img_urls
    images = ::Htmlarticle.download_images(img_urls)

    category = "电子科技、人工智能、信息通讯"
    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_time: ts, con_text: desp,attached_img_info: images,category: category}
    puts task.to_json
    #  "====item==task==#{task}"
    info = ::TData.save_one(task)
    return info
  end
end
