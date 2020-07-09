
class ThevergeCom

  def initialize
    @site = "THE  VEGRE"
    @prefix = "https://www.theverge.com"
    # RestClient.proxy = "http://192.168.112.1:1080/"
  end

  def list(body)
    tasks = []
    if body.blank?
      urls = ["https://www.theverge.com/ai-artificial-intelligence"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      # str = RestClient::Request.execute(method: :get,url:url,verify_ssl: false,:timeout =>10,:open_timeout =>10
      # )
      str = RestClient2.get(url)

      doc = Nokogiri::HTML(str.body)
      doc.search("div.c-compact-river h2 a").each do |item|
        link = item["href"] rescue ""
        next if link.blank?
        link = @prefix + link if !link.match(/^http/)
        body = {link:link}
        tasks << {mode:"item",body:URI.encode(body.to_json)}
      end
    end
    return tasks
  end

  def item(body)
    body = JSON.parse(URI.decode(body))
    puts link = body["link"]
    res = RestClient2.get(link).body
    doc = Nokogiri::HTML(res)
    tss = doc.search("time.c-byline__item").inner_text.strip rescue nil
    ts = Time.parse(tss).to_s rescue nil
    title = doc.search("h1.c-page-title").inner_text.strip rescue nil
    authors = []
    doc.search("div.c-byline span.c-byline__author-name").each do |au|
      au = au.inner_text.strip
      authors << au if au != ""
    end
    authors = authors.compact.uniq
    videos = []
    ss = doc.search("div.c-entry-content iframe")[0][:src] rescue ""
        if ss != ""
          video_id = ss.to_s.split("embed/")[1].split("?")[0]
           request_url = "https://www.youtube.com/get_video_info?video_id=#{video_id.to_s}"
            request_res = RestClient2.get(request_url)
         urires = URI.decode(request_res.to_s)
        # Rails.logger.info uriressplit = urires.split('"url":"')[1].split('","mimeType"')[0]
        # jsonres = JSON.parse(uriressplit)
        video_url = urires.split('"url":"')[1].split('","mimeType"')[0]
        viurl = URI.decode(URI.decode(video_url)).gsub('\u0026',"&")
           videos << viurl

        end
       puts attached_media_info = ::Htmlarticle.download_medias(videos) 
       images = []
    doc.search("div.l-col__main img").each do |src|
      img = src[:src]
      images << img
    end
    images = ::Htmlarticle.download_images(images) 
    desp = doc.search("div.c-entry-content").search("p,h3").collect{|x| x.inner_text.strip }.join("\n")
    files = []
    category = "人工智能/空间"

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info: attached_media_info}

    Rails.logger.info task
    info = ::TData.save_one(task)
    return info
  end
end
