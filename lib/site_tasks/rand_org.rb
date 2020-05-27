class RandOrg
  def initialize
    @site = "RAND-Qatar Policy Institute"

  end

  def list(body)
    # sleep 10
    tasks = []
    if body.blank?
      urls = ["https://www.rand.org/pubs.html"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:body}
      end
    else
      # url = body["url"]
      # res = RestClient.get(url)
      # doc = Nokogiri::HTML(res.body)
      # doc.search("div#results ul.teasers h3 a,ul.pub-list li a").each_with_index do |item,index|
      #   link = item["href"] rescue nil
      #   next if link.blank?
      #   link = @prefix + link if !link.match(/^http/)
      #   body = {link:link}
      #   tasks << {mode:"item",body:body}
      # end

      page = rand(0..1000)
      for i in page..page
        body = {link:"link_#{i}"}
        tasks << {mode:"item",body:body}
      end

    end
    return tasks
  end

  def item(body)
    # link = body["link"]
    # res = RestClient.get(link).body
    # doc = Nokogiri::HTML(res)
    # title = doc.search("h1")[0].inner_html.strip rescue nil
    # ts = Time.parse(doc.search("meta[name='rand-published-date']")[0]["content"] + @time_zone) rescue nil
    # ts = Time.parse(doc.search("meta[name='rand-date']")[0]["content"]).to_i rescue nil if ts.blank?
    # params = {doc:doc,content_selector:"div.product-main",html_replacer:"p||||h3||||li||||div||||h2",content_rid_html_selector:"div.conducted||||div#indicia||||section||||.external-link||||div.research-questions||||iframe"}
    # desp,html_content = ::Htmlarticle.get_html_content(params)
    # if desp.blank?
    #   doc = Nokogiri::HTML(res)
    #   params = {doc:doc,content_selector:"#page-content #srch",html_replacer:"p||||h3||||li||||div||||h2",content_rid_html_selector:".multimediaContentWrapper||||h2||||.full-bg-bottom||||#videoEmbed"}
    #   desp,html_content = ::Htmlarticle.get_html_content(params)
    # end
    #
    # images = doc.search("div.product-header img").map { |x| x["src"].match(/^http/) ? x["src"] : @prefix + x["src"] } rescue nil
    # files = doc.search("span.format-pdf a").map { |x| x["href"].match(/^http/) ? x["src"] : @prefix + x["href"] } rescue nil
    # authors = doc.search("div.js-column-height p.authors").inner_text.strip.gsub(/^by /i,"") rescue nil
    #
    # task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:html_content,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files}
    # puts "====item==task==#{task}"
    task = {data_address: body["link"],website_name:@site,data_spidername:self.class,data_snapshot_path:'12',con_title:'12', con_author: '12', con_time: Time.now, con_text: '12',attached_img_info: nil,attached_file_info: nil}
    error = save_one(task)
    return error
  end


  def save_one(task)
    a = ::TData.new
    a.data_address = task[:data_address]
    a.website_name = task[:website_name]
    a.data_spidername = task[:data_spidername]
    a.data_snapshot_path = task[:data_snapshot_path]
    a.data_source_type = task[:data_source_type]
    a.data_mode = task[:data_mode]
    a.data_time = Time.now
    a.con_title = task[:con_title]
    a.con_from = task[:con_from]
    a.con_author = task[:con_author]
    a.con_time = task[:con_time]
    a.con_text = task[:con_text]
    a.category = task[:category]
    a.attached_media_info = task[:attached_media_info]
    a.attached_img_info = task[:attached_img_info]
    a.attached_file_info = task[:attached_file_info]
    a.data_source_type = "website"
    a.data_mode = "spider"
    # puts a.to_json
    error = a.save_data
    return error

  end
end


