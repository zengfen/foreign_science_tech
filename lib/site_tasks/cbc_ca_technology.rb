class CbcCaTechnology
  def initialize
    #RestClient.proxy = "http://192.168.50.1:1080/"
    @site = "cbc广播新闻科学与科技频道"
  end

  def list(body)
    tasks = []
    lk = "https://www.cbc.ca/news/technology"

    str = RestClient.get(lk).body
    puts doc = Nokogiri::HTML(str)
    doc.search("a.contentWrapper,a.cardDefault").each do |item|
      link = "https://www.cbc.ca" + item[:href] rescue nil
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
   #link = "https://www.cbc.ca/news/technology/nodosaur-borealopelta-stomach-1.5600224"
    res = RestClient.get(link).body
    doc = Nokogiri::HTML(res)
    title = doc.search("h1.detailHeadline")[0].inner_text.strip rescue nil

    authors = doc.search(".bylineDetails .authorText a").collect{|x| x.inner_text.strip}
    # authors << JSON.parse(doc.search('script[type="application/ld+json"]').inner_text)["author"]["name"]
    ts = doc.search("time")[0][:datetime]
    puts ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")
    puts "*"*100
    json_doc = JSON.parse(doc.search('script[type="application/ld+json"]')[0].inner_text.strip)
    # []
    puts image_urls = json_doc["image"].map{|x| x["url"]} rescue nil
    images = ::Htmlarticle.download_images(image_urls)

    desp = doc.search(".storyWrapper").search("p,h2").collect{|x| x.inner_text.strip}.join("\n")
    # html_content = doc.search("div.cmn-article_text").search("p,div").to_s
    video = []
    json_doc["video"].each do |one|
      id = one["identifier"]
      url = "https://link.theplatform.com/s/ExhSPC/media/guid/2655402169/#{id}/meta.smil?feed=Player%20Selector%20-%20Prod&format=smil&mbr=true&manifest=m3u"
      doc1 = Nokogiri::HTML(RestClient.get(url))
      url1 = doc1.search("video")[0][:src]
      video << RestClient.get(url1).to_s.match(/http.+?m3u8/)[0]
    end

    p attached_media_info = ::Htmlarticle.download_m3u8(video)
    files = []
    category = "新闻综合"

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info:attached_media_info}
    # puts task.to_json
    info = ::TData.save_one(task)
    return info
  end
end
