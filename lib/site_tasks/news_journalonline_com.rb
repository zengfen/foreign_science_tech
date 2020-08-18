class NewsJournalonlineCom
  def initialize
    @site = "The Daytona Beach News-Journal"
    @prefix = "https://www.news-journalonline.com"
  end


  def list(body="")
    tasks = []
    lk = "https://www.news-journalonline.com/news"
    # lk = "https://www.news-journalonline.com/news?template=JSON&mime=json&c=25&start=1&topicEvergreen=false"
    res = RestClient2.get(lk)
    # doc = JSON.parse(res.body)
    # item_links = doc["main"].map { |x| x["link"] }
    doc = Nokogiri::HTML(res.body) rescue nil
    doc.search("dov.gnt_pr>a,div.gnt_m>a").each do |item|
      link = item["href"]
      next if link.blank?
      link = @prefix + link if !link.match(/^http/)
      body = {link:link}
      tasks << {mode:"item",body:URI.encode(body.to_json)}
    end
    return tasks
  end

  def item(body)
    task = JSON.parse(URI.decode(body))
    link = task["link"]
    res = RestClient2.get(link) rescue nil
    doc = Nokogiri::HTML(res.body) rescue nil
    authors = nil
    return if doc.blank?
    if link.match(/picture-gallery/)
      title = doc.search("h1.display-2").first.inner_text.strip rescue nil
      authors = doc.search("a.gnt_ar_by_a").map{|x| x.inner_text.strip} rescue nil
      images = doc.search("media-gallery-vertical slide").map{|x| x["original"].match(/^http/)? x["original"] : @prefix + x["original"] } rescue []
      # images += doc.search("div.gnt_ar_b aside a.gnt_em_ifg_ph").map{|x| x["href"].match(/^http/)? x["href"] : @prefix + x["href"] } rescue []
      desp = []
      doc.search("media-gallery-vertical slide").each do |item|
        desp << item["caption"]
        desp << item["author"]
      end
      desp = desp.join("\n")

      params = {doc:doc,content_selector:"media-gallery-vertical",html_replacer:"p||||br||||li||||div",content_rid_html_selector:"div[@aria-label='advertisement']||||figure:nth-child(1)"}
      desp,_ = Htmlarticle.get_html_content(params)
      created_time = Time.parse(doc.search("story-timestamp")[0]["publish-date"]) rescue nil
    else
      title = doc.search("h1.gnt_ar_hl").first.inner_text.strip rescue nil
      authors = doc.search("a.gnt_ar_by_a").map{|x| x.inner_text.strip} rescue nil
      images = doc.search("div.gnt_ar_b figure img").map{|x| x["src"].match(/^http/)? x["src"] : @prefix + x["src"] } rescue []
      # images += doc.search("div.gnt_ar_b aside a.gnt_em_ifg_ph").map{|x| x["href"].match(/^http/)? x["href"] : @prefix + x["href"] } rescue []

      params = {doc:doc,content_selector:"div.gnt_ar_b",html_replacer:"p||||br||||li",content_rid_html_selector:"div[@aria-label='advertisement']||||figure:nth-child(1)"}
      desp,_ = Htmlarticle.get_html_content(params)
      created_time = Time.parse(doc.to_s.match(/"datePublished":"(.*?)"/)[1]) rescue nil
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
          desp += item2.to_s.gsub_html.strip + "\n"
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

