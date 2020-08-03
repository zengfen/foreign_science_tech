class NewsJournalonlineCom
  def initialize
    @site = "The Daytona Beach News-Journal"
  end


  def list(body="")
    tasks = []
    # https://www.news-journalonline.com/news
    lk = "https://www.news-journalonline.com/news?template=JSON&mime=json&c=25&start=1&topicEvergreen=false"
    res = RestClient2.get(lk)
    doc = JSON.parse(res.body)
    item_links = doc["main"].map { |x| x["link"] }
    item_links.each do |link|
      body = {link:link}
      tasks << {mode:"item",body:URI.encode(body.to_json)}
    end
    return tasks
  end

  def item(body)
    task = JSON.parse(URI.decode(body))
    link = task["link"]
    res = RestClient2.get(link).body rescue nil
    doc = Nokogiri::HTML(res) rescue nil
    authors = nil
    return if doc.blank?
    if link.match(/photogallery/)
      desp_str = doc.search("script").find { |x| x.to_s.match(/var __gh__coreData/) }.inner_text
      desp_json = JSON.parse(desp_str.match(/__gh__coreData.content=(.*?)__gh__coreData.pageData = /m)[1].strip.gsub(/;$/, "")) rescue {}
      title = desp_json["title"]
      # abstract = desp_json["summary"]
      images = desp_json["items"].map { |x| x["link"]}.flatten.uniq rescue []
      image_desps = desp_json["items"].map { |x| x["caption"]} rescue []
      desp,html_content = "",""
      image_desps.each do |image_desp|
        desp += image_desp + "\n"
        html_content = html_content.to_s + "<p>" + image_desp + "</p>"
      end
      created_time = Time.parse(desp_json["pubDate"] + " -0500").to_i rescue nil
    else
      title = doc.search("h1.headline").first.inner_text.strip rescue nil
      # 正文
      desp_str = doc.search("script").find { |x| x.to_s.match(/var __gh__coreData/) }.inner_text

      desp_json = JSON.parse(desp_str.match(/__gh__coreData.content=(.*?)__gh__coreData.content.bylineFormat = /m)[1].strip.gsub(/;$/, "").strip.gsub(/,\r\n\t\],\r\n\t\"rail\":/, "\r\n\t\],\r\n\t\"rail\":")) rescue {}

      # abstract = desp_json["summary"].gsub_html.strip rescue nil
      html_content_str = desp_json["body"].join("") rescue nil

      desp, html_content = '', ''
      Nokogiri::HTML(html_content_str.to_s).children.each do |item|
        desp, html_content = get_desp(desp, html_content, item)
      end

      images = desp_json["relatedContent"]["items"].select { |x| ["mainImage", "images", "gallery"].include?(x["type"]) }.map { |x| x["items"].map { |y| y["link"] } }.flatten rescue nil
      images.uniq!
      image_desps = desp_json["relatedContent"]["items"].select { |x| ["mainImage", "images", "gallery"].include?(x["type"]) }.map { |x| x["items"].map { |y| y["caption"] } }.flatten rescue []

      image_desps.each do |image_desp|
        desp += image_desp + "\n"
        html_content = html_content.to_s + "<div>" + image_desp + "</div>"
      end
      desp = (desp.split("\n") - [""]).join("\n")

      authors = desp_json["byline"].map { |x| x["name"] } rescue nil
      created_time = Time.parse(desp_json["pubDateFormat"]["yyyy-mm-ddThh:mm:ss"]).to_i rescue nil
    end

    images = ::Htmlarticle.download_images(images.map{|x| URI.encode(x)}) if images.present?

    category = "新闻综合"
    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: created_time, con_text: desp,attached_img_info: images,attached_file_info: [],category: category,attached_media_info:[]}

    info = ::TData.save_one(task)
    return info
  end

  def get_desp(desp, html_content, item)
    if item.children.present?
      item.children.each do |item2|
        if ["p","h2","li"].include?(item2.name) && item2.search("br").blank?
          desp += item2.inner_text.gsub_html.strip + "\n"
          html_content += item2.to_s
        elsif item2.name == "text"
          desp += item2.to_s.gsub_html.strip
          html_content += item2.to_s
        elsif item2.name == "br"
          desp += "\n"
          html_content += item2.to_s
        else
          desp, html_content = get_desp(desp, html_content, item2)
        end
      end
    else
      desp += item.to_s.gsub_html.strip
      html_content += item.to_s
    end
    return desp, html_content
  end


end


class String
  def gsub_html
    self.gsub(/(?imx)<script.+?script>/,"").gsub(/(?imx)<style(.+?)style>/,"").gsub(/(?imx)<(\S*?)[^>]*>.*?|<.*? \/>/,"")
  end
end

