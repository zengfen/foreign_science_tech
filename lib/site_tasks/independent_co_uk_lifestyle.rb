class IndependentCoUkLifestyle

  def initialize
    @site = "independent-technology"
    @prefix = "https://www.independent.co.uk"
  end

  def list(body)
    tasks = []
    if body.blank?
      urls = ["https://www.independent.co.uk/life-style/gadgets-and-tech"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      str = RestClient.get(url).body
      doc = Nokogiri::HTML(str)
      doc.search("div.type-article>a").each do |item|
        link = item["href"] rescue nil
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
    title = doc.search("h1.headline>span")[0].inner_text.strip rescue nil

    authors = []
    authors_temp = doc.search('meta[name="article:author_name"]')[0]["content"] rescue nil
    authors = authors_temp.split(", ")

    ts = doc.search('meta[property="article:published_time"]')[0]["content"]
    ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")

    # []
    image_urls = doc.search("figure amp-img").map{|x| x["src"]} rescue nil
    image_urls = image_urls.uniq
    images = ::Htmlarticle.download_images(image_urls)
    # doc.search("p.author-feedback-text").remove
    desp = doc.search("div.body-content").search("p,h2").collect{|x| x.inner_text.strip }.join("\n")

    files = []
    category = "新闻综合"
    media = []
    media_url = []
    media_url << doc.search('meta[property="og:video"]')[0]["content"] rescue nil
    media = ::Htmlarticle.download_medias(media_url) rescue nil
    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info: media}
    puts task.to_json

    info = ::TData.save_one(task)
    return info
  end
end
