class SmhComAuTechnology
  def initialize
    #RestClient.proxy = "http://192.168.50.1:1080/"
    @site = "悉尼先驱晨报科技频道"
  end

  def list(body)
    tasks = []
    lk = "https://www.smh.com.au/technology"
    since="QXNzZXQ6InA1NHU4cCI="
    for i in 1..50
      lk = "https://api.smh.com.au/graphql?query=query%20CategoryIndexMoreQuery(%20%24brand%3A%20String!%20%24count%3A%20Int!%20%24path%3A%20String!%20%24since%3A%20ID%20%24types%3A%20%5BString!%5D!%20)%20%7B%20assetsConnection%3A%20assetsConnectionByNavigationPath(brand%3A%20%24brand%2C%20path%3A%20%24path%2C%20count%3A%20%24count%2C%20sinceID%3A%20%24since%2C%20types%3A%20%24types)%20%7B%20...AssetsConnectionFragment_showMoreData%20%7D%20%7D%20fragment%20AssetsConnectionFragment_showMoreData%20on%20AssetsConnection%20%7B%20assets%20%7B%20...AssetFragmentFragment_assetDataWithTag%20id%20%7D%20pageInfo%20%7B%20endCursor%20hasNextPage%20%7D%20%7D%20fragment%20AssetFragmentFragment_assetDataWithTag%20on%20Asset%20%7B%20...AssetFragmentFragment_assetData%20tags%20%7B%20primaryTag%20%7B%20...AssetFragment_tagFragment%20%7D%20%7D%20%7D%20fragment%20AssetFragmentFragment_assetData%20on%20Asset%20%7B%20id%20asset%20%7B%20about%20byline%20duration%20headlines%20%7B%20headline%20%7D%20live%20totalImages%20%7D%20label%20urls%20%7B%20canonical%20%7B%20path%20brand%20%7D%20external%20published%20%7B%20brisbanetimes%20%7B%20path%20%7D%20canberratimes%20%7B%20path%20%7D%20smh%20%7B%20path%20%7D%20theage%20%7B%20path%20%7D%20watoday%20%7B%20path%20%7D%20%7D%20%7D%20featuredImages%20%7B%20landscape16x9%20%7B%20...ImageFragment%20%7D%20landscape3x2%20%7B%20...ImageFragment%20%7D%20portrait2x3%20%7B%20...ImageFragment%20%7D%20square1x1%20%7B%20...ImageFragment%20%7D%20%7D%20assetType%20dates%20%7B%20modified%20published%20%7D%20sponsor%20%7B%20name%20%7D%20%7D%20fragment%20AssetFragment_tagFragment%20on%20AssetTagDetails%20%7B%20displayName%20urls%20%7B%20published%20%7B%20brisbanetimes%20%7B%20path%20%7D%20canberratimes%20%7B%20path%20%7D%20smh%20%7B%20path%20%7D%20theage%20%7B%20path%20%7D%20watoday%20%7B%20path%20%7D%20%7D%20%7D%20%7D%20fragment%20ImageFragment%20on%20Image%20%7B%20data%20%7B%20animated%20aspect%20autocrop%20cropWidth%20id%20mimeType%20offsetX%20offsetY%20zoom%20%7D%20%7D%20&variables=%7B%22brand%22%3A%22smh%22%2C%22count%22%3A10%2C%22path%22%3A%22%2Ftechnology%22%2C%22since%22%3A%22#{since}%22%2C%22types%22%3A%5B%22article%22%2C%22bespoke%22%2C%22featureArticle%22%2C%22gallery%22%2C%22liveArticle%22%2C%22video%22%5D%7D"
      doc = JSON.parse(RestClient.get(lk))
      since = doc["data"]["assetsConnection"]["pageInfo"]["endCursor"]
      doc["data"]["assetsConnection"]["assets"].each do |one|
        puts url = "https://www.smh.com.au" + one["urls"]["canonical"]["path"]
        body = {link:url}
        puts body.to_json

        tasks << {mode:"item",body:URI.encode(body.to_json)}
      end
    end

    # str = RestClient.get(lk).body
    # doc = Nokogiri::HTML(str)
    # doc.search('a[data-test="article-link"]').each do |item|
    #   p link = "https://www.smh.com.au" + item[:href] rescue nil
    #   body = {link:link}
    #   puts body.to_json
    #   tasks << {mode:"item",body:URI.encode(body.to_json)}
    #   # tasks << {mode:"item",body:body}
    # end
    return tasks
  end

  def item(body)
    body = JSON.parse(URI.decode(body))
    puts link = body["link"]
    # link = "https://www.smh.com.au/technology/spacex-prototype-explosion-20200530-p54xx3.html"
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
