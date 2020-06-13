class ElectronicdesignCom

  def initialize
    @site = "electronic  design"
    @prefix = "https://www.electronicdesign.com"
    @header = {
      "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
      # "Accept-Encoding": "gzip, deflate, br",
      "Accept-Language": "zh-CN,zh;q=0.9,zh-TW;q=0.8,en-US;q=0.7,en;q=0.6",
      "Cache-Control": "no-cache",
      "Cookie": "SPSI=af8237f08d40af202333cae2849df0d1; UTGv2=h4c3ba6cb3d735c2df9529d6bede617cef64; __gads=ID=4abd045fdaa7ac35:T=1591341428:S=ALNI_MYWUz4k1aFxqL06ukBoNLIpsKZKxw; _ga=GA1.2.555404389.1591341427; _gid=GA1.2.1483667478.1591341428; oly_enc_id=null; oly_anon_id=%22F-398b7c1c-524b-4948-a77c-090912aef499%22; BCSessionID=c2536f4f-4962-4484-a931-497e6a704554; hasLiveRampMatch=true; __adroll_fpc=152e6b29912e3bbbcac537c15b72501b-1591341438050; _fbp=fb.1.1591341442741.709406285; spcsrf=41a5c05b902e20954d4c02eb32204446; PRLST=QI; dpm_url_count=4; __ar_v4=45GZFZBG65GTZP2EESFCXP%3A20200605%3A2%7C3BQ2N447KNEODAIZTDTY2B%3A20200605%3A2%7CIXZC4QKE6BDSVNBBOX54JQ%3A20200605%3A2; adOtr=32USa088f4d; dpm_time_site=848.018",
      "authority": "www.electronicdesign.com",
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36"
    }
  end

  def list(body)
    tasks = []
    if body.blank?
      urls = ["https://www.electronicdesign.com/"]
      urls.each do |url|
        body = {url:url}
        tasks << {mode:"list",body:URI.encode(body.to_json)}
      end
    else
      body = JSON.parse(URI.decode(body))
      url = body["url"]
      str = RestClient2.get(url,header = @header).body
      doc = Nokogiri::HTML(str)
      doc.search("div.page-grid__bottom-row h5.node__title>a").each do |item|
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
    res = RestClient2.get(link,header = @header).body
    doc = Nokogiri::HTML(res)

    json_data = doc.search("script").to_s.match(/dataLayer.push\((.*?)\}\]\}\)/)[1].to_s + "}]}" rescue nil
    jdoc = JSON.parse(json_data)
    title = jdoc["content"]["name"]
    ts = Time.parse(jdoc["content"]["published"]).strftime("%Y-%m-%d %H:%M:%S")
    authors = jdoc["authors"].map { |e| e["name"] }
    # title = doc.search("div.page-grid__bottom-row>div.content-page-node h1.content-page-card__content-name")[0].inner_text.strip rescue nil
    # authors = []
    # authors << doc.search('span.page-attribution__content-name>a')[0]["content"] rescue nil
    # ts = doc.search('meta[property="article:published_time"]')[0]["content"]
    # ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")

    image_urls = []
    puts image_urls = doc.search("div.content-page-node")[0].search("span[data-embed-type='image']>img").map{|x| x["data-src"]} 
    image_urls << doc.search('meta[property="og:image"]')[0]["content"] rescue nil
    image_urls = image_urls.uniq
    images = ::Htmlarticle.download_images(image_urls)
    # doc.search("p.author-feedback-text").remove
    # div.page-grid__bottom-row>  ||div.content-page-node div.page-contents div.page-contents__content-body
    desp = doc.search("div.content-page-node")[0].search("div.page-contents div.page-contents__content-body").search("p,h2").collect{|x| x.inner_text.strip }.join("\n")

    files = []
    category = "人工智能技术、无人系统、平台技术、网络与信息技术、电子科学技术"
    media = []

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info: media}


    info = ::TData.save_one(task)
    return info
  end
end
