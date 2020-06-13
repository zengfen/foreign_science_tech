require 'rest-client'
require 'nokogiri'
require 'time'
require 'json'
class String
  def gsub_html
    self.gsub(/(?imx)<script.+?script>/,"").gsub(/(?imx)<style(.+?)style>/,"").gsub(/(?imx)<(\S*?)[^>]*>.*?|<.*? \/>/,"")
  end
end
class GigaomCom

  def initialize
    @site = "GIGAOM"
    @prefix = "https://gigaom.com"
  end

  def list(body)
    tasks = []
    if body.blank?
      urls = ["https://gigaom.com/"]
      # urls = ["https://time.com/section/tech/?page=1","https://time.com/section/tech/?page=2","https://time.com/section/tech/?page=3","https://time.com/section/tech/?page=4","https://time.com/section/tech/?page=5","https://time.com/section/tech/?page=6"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      str = RestClient.get(url).body
      doc = Nokogiri::HTML(str)
      doc.search(".main-content article").each do |item|
        puts sponsored = item.search("footer div.sponsored-by>span").inner_text.strip
        next if sponsored.include?("Sponsored by")
        link = item.search("h4.deck>a")[0]["href"] rescue nil
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
    res = RestClient.get(link).body
    doc = Nokogiri::HTML(res)
    title = doc.search("h1.entry-title")[0].inner_text.strip rescue nil

    authors = []
    authors_temp = doc.search("span.entry-author")[0].inner_text.strip rescue nil
    if authors_temp.blank?
      doc.search("script").to_s.match(/creator":"(.*?)"\}\<\/script\>/)[1]
    end
    authors << authors_temp

    ts = doc.search("time.entry-time")[0]["datetime"] rescue nil
    if ts.blank?
      ts = doc.search("script").to_s.match(/dateCreated":"(.*?)\"\,\"articleSection/)[1]
    end
    if ts == ""
      return
    end
    puts ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")

    # []
    image_urls = doc.search("div.entry-meta img.wp-post-image").map{|x| x["src"]} rescue nil
    if image_urls.blank?
      image_urls << doc.search("script").to_s.match(/thumbnailUrl\"\:\"(.*?)\"\,\"dateCreated/)[1].gsub(/\\/,"")
    end
    image_urls = image_urls.compact.uniq
    images = ::Htmlarticle.download_images(image_urls)
    # div.entry-content ul.social-share-links,div.voice-in-ai-link-back-embed
    doc.search("section.related-analysts,div.entry-content ul.social-share-links,div.voice-in-ai-link-back-embed,div#ad-a-small-container,div.secondary-column,div.info div.show-info,div.transcript").remove
    # params = {doc:doc,content_selector:"article div.entry-content",html_replacer:"p||||h3||||h2",content_rid_html_selector:""}
    # desp,_ = ::Htmlarticle.get_html_content(params)
    desp = doc.search("article div.entry-content").search("p,h2,h3,ul>li").collect{|x| x.inner_text.strip }.join("\n")

    files = []
    category = "人工智能、无人系统、平台技术、网络与信息技术、电子科学技术、量子技术、光学技术、动力能源技术、新材料与新工艺、"
    media = []
    media_url = []
    doc.search("div.responsive-embed p iframe").each do |video|
      if video["src"].include? "youtube"
        src = video["src"]
        Rails.logger.info video_id = src.to_s.split("embed/")[1].split("?")[0]
        request_url = "https://www.youtube.com/get_video_info?video_id=#{video_id.to_s}"
        request_res = RestClient.get(request_url)
        urires = URI.decode(request_res.to_s)
        Rails.logger.info "**"*100
        # Rails.logger.info uriressplit = urires.split('"url":"')[1].split('","mimeType"')[0]
        # jsonres = JSON.parse(uriressplit)
        Rails.logger.info video_url = urires.split('"url":"')[1].split('","mimeType"')[0]
        Rails.logger.info viurl = URI.decode(URI.decode(video_url)).gsub('\u0026',"&")
        media_url << viurl
      else
        media_url << video["src"]
      end
    end
    media_url << doc.search("script").to_s.match(/\'url\'\:\ \"(.*?)\.mp3\"\,/)[1] + ".mp3" rescue []
    puts media_url = media_url.compact.uniq
    Rails.logger.info media_url
    if media_url.join.include?(".mp3")
      media = download_mp3(media_url)
    else
      media = ::Htmlarticle.download_medias(media_url)
    end
    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info: media}
    puts task.to_json

    info = ::TData.save_one(task)
    return info
  end

  # mp3下载
  def download_mp3(urls)
    path = "#{Rails.root}/public/medias"
    files = []
    urls.each do |url|
      res = RestClient.get(url)
      name = Digest::MD5.hexdigest(url) + ".mp3"
      if File.exist? "#{path}/#{name}"
        files << "/medias/#{name}"
        next
      end
      File.open("#{path}/#{name}", 'wb') { |f| f.write(res.body) }
      files << "/medias/#{name}"
    end
    return files
  end
end
