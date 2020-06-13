class ReutersComMedia
  def initialize
    @site = "reuters-technology-media"
    @prefix = "https://www.reuters.com/news/media"
  end

  def list(body)

    # RestClient.proxy = "http://192.168.16.1:1080/"
    tasks = []
    @headers = {
      "authority" => "www.reuters.com",
      "method"=>"GET",
      "path"=>"/news/media",
      "scheme"=>"https",
      "accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      "accept-encoding"=>" deflate, br",
      "accept-language"=>"zh-CN,zh;q=0.9",
      "cache-control"=>"max-age=0",
      "cookie"=>"ajs_anonymous_id=%229bebfaa5-bc85-4f8e-9607-54755866311b%22; _cb_ls=1; _ga=GA1.2.1678434211.1591066165; _fbp=fb.1.1591066171215.2130927104; __tbc=%7Bjzx%7Dyo9xUxAKwg32SeQvuAZGbXig6u5CwB8FtUYvbx0xXLgFyjCh6rjqzCPIJxT1FpOy-WriulMNPbCFsb-EGAd6i-vJJmhnG09sHhm38p9NgUUCOnAbvwfkAqsqt8QpTMh0HzyVzbU0qDL8Htc3rl51Vg; __pat=-14400000; xbc=%7Bjzx%7DBtS3PHr8KcpV6uj81Rx7DABVMccyC_xq_1VPUP4eVVMcR0nrm5-pcBSNAzdX2mk36d8mimHtHZe5l6HkT7ijdI42vfARtPY5wVcV-ORPJVwogNekqF_EMGuFVqmMRYPK; ajs_user_id=%229bebfaa5-bc85-4f8e-9607-54755866311b%22; __gads=ID=49bef106a310f31d:T=1591066176:S=ALNI_MavBu3vkjOYtlJYwLjgCD9BL-D8TQ; aam_uuid=61217900958311557252481361907219291074; _cb=BTSc8uDX_xRbB4UVUm; i18next=en; _v__chartbeat3=Bj0FnrDHD95-CwRCFU; mcxSurveyQuarantine=mcxSurveyQuarantine; _gid=GA1.2.575391134.1591580467; AMCVS_4579BF7A580A3C6A0A495DAF%40AdobeOrg=1; AMCV_4579BF7A580A3C6A0A495DAF%40AdobeOrg=1585540135%7CMCIDTS%7C18422%7CMCMID%7C60782026187160902952504418358243586168%7CMCAAMLH-1592185268%7C9%7CMCAAMB-1592185268%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1591587668s%7CNONE%7CvVersion%7C4.4.0; McxPageVisit=41; mnet_session_depth=1%7C1591580469806; __pvi=%7B%22id%22%3A%22v-2020-06-08-09-41-10-636-sxI0q0SN76uBw0qn-953e2c6186cad884ca3295c4ecddbd6b%22%2C%22domain%22%3A%22.reuters.com%22%2C%22time%22%3A1591580471272%7D; _chartbeat2=.1591066197060.1591580481540.1111001.zOBNOMHr3LDopT3YBHQFqEBDDyYs.1; _cb_svref=null; xdefccpm=no; _gat=1",
      "sec-fetch-dest"=>"document",
      "sec-fetch-mode"=>"navigate",
      "sec-fetch-site"=>"cross-site",
      "sec-fetch-user"=>"?1",
      "upgrade-insecure-requests"=>"1",
      # "user-agent"=>"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.138 Safari/537.36"
    }
    if body.blank?
      urls = ["https://www.reuters.com/news/media"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      res = RestClient2.get(url,headers=@headers)
      doc = Nokogiri::HTML(res.body)
      doc.search("div.column1 div.story-content a").each_with_index do |item,index|
        link = item["href"] rescue nil
        link ="https://www.reuters.com/article" + link if !link.match(/^http/)
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
    res = RestClient2.get(link).body
    doc = Nokogiri::HTML(res)
    title = doc.search("div.ArticleHeader_content-container h1.ArticleHeader_headline")[0].inner_text.strip rescue nil

    timepublished = doc.search("meta[property='og:article:published_time']")[0]["content"]
    ts = Time.parse(timepublished).strftime("%Y-%m-%d %H:%M:%S") rescue nil
    timemodified = doc.search("meta[property='og:article:modified_time']")[0]["content"]
    ts = Time.parse(timemodified).strftime("%Y-%m-%d %H:%M:%S") rescue nil if ts.blank?

    params = {doc:doc,content_selector:"div.StandardArticleBody_body",html_replacer:"p",content_rid_html_selector:"div"}
    desp,_ = ::Htmlarticle.get_html_content(params)

    image_urls = []
    image_urls << doc.search("meta[property='og:image']")[0]["content"].to_s
    images = ::Htmlarticle.download_images(image_urls)

    media_urls = []
    if doc.to_s.match("\"videos\":")
      video_urls_doc = doc.to_s.match(/window.RCOM_Data = (.+?)}};\<\/script>/)[1] + "}}"
      jdoc = "{\"videos\":" + video_urls_doc.to_s.match(/"videos":(.+?)\],/)[1].to_s + "]}"
      jdoc = JSON.parse(jdoc)
      jdoc["videos"].each do |two|
        puts two["url"]
        media_urls << two["url"].to_s.gsub("//","")
      end
    end
    medias = ::Htmlarticle.download_medias(media_urls)
    category = "人工智能技术、无人系统、平台技术、网络与信息技术、电子科学技术"
    authors = []
    authors << doc.search("meta[name='Author']")[0]["content"].to_s

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,category: category,attached_media_info:medias}

    # puts "====item==task==#{task}"
    info = ::TData.save_one(task)
    return info
  end

end
