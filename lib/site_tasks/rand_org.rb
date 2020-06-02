class RandOrg
  def initialize
    @site = "RAND Corporation"
    @prefix = "https://www.rand.org"
  end

  def list(body)
    # sleep 10
    tasks = []
    if body.blank?
      urls = ["https://www.rand.org/pubs.html"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      res = RestClient.get(url)
      doc = Nokogiri::HTML(res.body)
      doc.search("div#results ul.teasers h3 a,ul.pub-list li a").each_with_index do |item,index|
        next if index > 4
        link = item["href"] rescue nil
        next if link.blank?
        link = @prefix + link if !link.match(/^http/)
        body = {link:link}
        puts body
        tasks << {mode:"item",body:URI.encode(body.to_json)}
      end

      # page = rand(0..1000)
      # for i in page..page
      #   body = {link:"link_#{i}"}
      #   tasks << {mode:"item",body:body}
      # end

    end
    return tasks
  end

  def item(body)
    body = JSON.parse(URI.decode(body))
    link = body["link"]
    res = RestClient.get(link).body
    doc = Nokogiri::HTML(res)
    title = doc.search("h1")[0].inner_text.strip rescue nil
    ts = Time.parse(doc.search("meta[name='rand-published-date']")[0]["content"] ) rescue nil
    ts = Time.parse(doc.search("meta[name='rand-date']")[0]["content"]) rescue nil if ts.blank?
    params = {doc:doc,content_selector:"div.product-main",html_replacer:"p||||h3||||li||||div||||h2",content_rid_html_selector:"div.conducted||||div#indicia||||section||||.external-link||||div.research-questions||||iframe"}
    desp,_ = ::Htmlarticle.get_html_content(params)
    if desp.blank?
      doc = Nokogiri::HTML(res)
      params = {doc:doc,content_selector:"#page-content #srch",html_replacer:"p||||h3||||li||||div||||h2",content_rid_html_selector:".multimediaContentWrapper||||h2||||.full-bg-bottom||||#videoEmbed"}
      desp, = ::Htmlarticle.get_html_content(params)
    end

    image_urls = doc.search("div.product-header img").map { |x| x["src"].match(/^http/) ? x["src"] : @prefix + x["src"] } rescue nil
    images = ::Htmlarticle.download_images(image_urls)

    files = doc.search("span.format-pdf a").map { |x| x["href"].match(/^http/) ? x["src"] : @prefix + x["href"] } rescue nil
    authors = doc.search("div.js-column-height p.authors").inner_text.strip.gsub(/^by /i,"") rescue nil

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files}
    puts task
    task
    # puts "====item==task==#{task}"
    info = ::TData.save_one(task)
    return info
  end



end


