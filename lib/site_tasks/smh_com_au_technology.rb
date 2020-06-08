class SmhComAuTechnology
  def initialize
    #RestClient.proxy = "http://192.168.50.1:1080/"
    @site = "悉尼先驱晨报科技频道"
  end

  def list(body)
    tasks = []
    lk = "https://www.smh.com.au/technology"

    str = RestClient.get(lk).body
    doc = Nokogiri::HTML(str)
    doc.search('a[data-test="article-link"]').each do |item|
      p link = "https://www.smh.com.au" + item[:href] rescue nil
      body = {link:link}
      puts body.to_json
      tasks << {mode:"item",body:URI.encode(body.to_json)}
      # tasks << {mode:"item",body:body}
    end
    return tasks
  end

  def item(body)
    body = JSON.parse(URI.decode(body))
    puts link = body["link"]
    link = "https://www.smh.com.au/technology/spacex-prototype-explosion-20200530-p54xx3.html"
    puts res = RestClient.get(link).body
    doc = Nokogiri::HTML(res)
    title = doc.search('h1[data-test="headline"]')[0].inner_text.strip rescue nil

    authors = doc.search('span[itemprop="author"] a').collect{|x| x.inner_text.strip}
    # authors << JSON.parse(doc.search('script[type="application/ld+json"]').inner_text)["author"]["name"]
    ts = doc.search("time")[0][:datetime]
    puts ts = Time.parse(ts).strftime("%Y-%m-%d %H:%M:%S")
    p image_urls = doc.search('picture img').map{|x| x[:src]} rescue nil
    images = ::Htmlarticle.download_images(image_urls)
    p desp = doc.search("section .undefined").search("p").collect{|x| x.inner_text.strip}.join("\n")
    # html_content = doc.search("div.cmn-article_text").search("p,div").to_s
    puts video_account = doc.search('video')[0][:"data-account"] rescue ""
    video = []
    if video_account != ""
      headers ={"Accept"=>"application/json;pk=BCpkADawqM2NV5FAQFyTZYWdNAxlCI9DcJ-_KJXZb45meqqlgz82zreoi8Bfe3dEE8mrhE6JtHDs06dJQ44vZo7v-avd_WOocm4cZvoyyq8fDkoiH_4hzPy8wUoSYcTm995KYr24uyzgfOv1",
                "Accept-Encoding"=>"gzip, deflate, br",
                "Accept-Language"=>"zh-CN,zh;q=0.9,en;q=0.8",
                "Connection"=>"keep-alive",
                "DNT"=>"1",
                "Host"=>"edge.api.brightcove.com",
                "Origin"=>"https://www.smh.com.au",
                "Referer"=>link,
                "Sec-Fetch-Mode"=>"cors",
                "Sec-Fetch-Site"=>"cross-site",
                "User-Agent"=>"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.88 Safari/537.36"}
      puts video_id = doc.search("video")[0][:"data-video-id"]
      video_lk = "https://edge.api.brightcove.com/playback/v1/accounts/#{video_account}/videos/#{video_id}"
      puts video_json = JSON.parse(RestClient.get(video_lk,headers=headers))
      puts video << video_json["sources"][0]["src"]
    end
    files = []
    attached_media_info = ::Htmlarticle.download_m3u8(video)
    category = "新闻综合"

    task = {data_address: link,website_name:@site,data_spidername:self.class,data_snapshot_path:res,con_title:title, con_author: authors, con_time: ts, con_text: desp,attached_img_info: images,attached_file_info: files,category: category,attached_media_info:attached_media_info}
    # puts task.to_json
    info = ::TData.save_one(task)
    return info
  end
end
