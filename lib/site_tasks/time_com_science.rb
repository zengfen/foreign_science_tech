class TimeComScience

  def initialize
    @site = "TIME-科学类"
    @prefix = "https://time.com"
  end

  def list(body)
    tasks = []
    if body.blank?
      urls = ["https://time.com/section/science/"]
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
    if authors_temp.include?("/ AP")
      authors_temp = authors_temp.gsub(/\ \/\ AP/,"")
    end
    authors << authors_temp

    puts ts = doc.search("div.published-date").inner_text.strip
    puts ts = Time.parse(ts).to_s

    # [] 		
    puts image_urls = doc.search("div.image-and-burst div.lead-media").map{|x| x["data-src"]} rescue nil
    puts images = ::Htmlarticle.download_images(image_urls)
    doc.search("p.author-feedback-text").remove
    desp = doc.search("div#article-body div.padded").search("p").collect{|x| x.inner_text.strip }.join("\n")

    files = []
    category = "新闻综合"
    media = []
    # https://edge.api.brightcove.com/playback/v1/accounts/293884104/videos/6159839695001
    media_prefix = "https://players.brightcove.net/293884104/gh5LeNtQaQ_default/index.html?videoId="
    # videoId = ""
    doc.search('video').each do |item|
      # videoId += item
      videoId = item["data-video-id"]
      media << media_prefix + "#{videoId}"
    end
    puts media
    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info: media}
    puts task.to_json

    info = ::TData.save_one(task)
    return info
  end
end
