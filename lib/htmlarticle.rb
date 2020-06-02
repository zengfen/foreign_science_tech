class Htmlarticle

  def initialize(text, options = {})
    @text = text
    @options = options
    @content = ""
  end

  # 参数说明
  # doc 源代码  必填参数
  # content_selector 正文规则  必填参数
  # content_replacer 正文替换正则
  # content_filter 正文过滤
  # content_rid_html_selector 正文剔除html标签
  # html_replacer html换行标签
  # html_replacer_for_no_tag_line 无标签文字是否按照同级换行标签换行 0 不处理 1 换行处理
  # params = {doc:doc,content_selector:content_selector,content_rid_html_selector:content_rid_html_selector,html_replacer:html_replacer,html_replacer_for_no_tag_line:html_replacer_for_no_tag_line,content_replacer:content_replacer,content_filter:content_filter}
  # 示例用法
  # doc = Nokogiri::HTML(res.body)
  # content_selector = "div.content"
  # html_replacer = "p"
  # params = {doc:doc,content_selector:content_selector,html_replacer:html_replacer}
  # desp,html_content = Htmlarticle.get_html_content(params)
  def self.get_html_content(params)
    desp_buff, html_content, desp = "", "", ""
    doc = params[:doc]
    content_selector = params[:content_selector].to_s.split("||||")
    html_replacer = params[:html_replacer].to_s.split("||||")
    html_replacer_for_no_tag_line = params[:html_replacer_for_no_tag_line]
    content_rid_html_selector = params[:content_rid_html_selector].to_s.split("||||")
    content_selector.each do |v|
      doc_content = doc.clone
      html_content = ""
      doc_content.search(v).each do |s|
        # 剔除不需要的节点
        content_rid_html_selector.each do |rid|
          s.search(rid).remove
        end
        # 处理html_content
        html_content += s.to_s if s.present?
      end
      # 处理 desp
      doc_content.search(v).each do |s|
        if html_replacer.count > 0 && html_replacer[0].present?
          if html_replacer.include? s.name
            desp_buff += "\n"
          end
        end
        s.children.each do |n|
          desp_buff = get_desp(n, desp_buff, html_replacer, html_replacer_for_no_tag_line)
        end
      end
      # 处理空格和换行
      # desp_buff = desp_buff.gsub("\n","").strip
      break if html_content.present? && desp_buff.present?
    end

    filters = params[:content_filter].to_s.split("||||")
    filters.each do |filter|
      if desp_buff.include? filter
        desp_buff = ""
        html_content = ""
        break
      end
    end

    content_replacer = params[:content_replacer].to_s
    if content_replacer.present?
      content_replacer.split("||||").each do |replacer|
        desp_buff = desp_buff.gsub(replacer, "") if replacer.present?
        if replacer.present?
          replacer_arr = replacer.split("&&&&")
          desp_buff = desp_buff.gsub(replacer_arr[0], "")
          html_content = html_content.gsub(replacer_arr[1], "") if replacer_arr[1].present?
        end
      end
    end


    desp = ""
    desp_buff.split("\n").each do |v|
      desp += v.strip + "\n" if v.strip.present?
    end

    return desp, html_content
  end

  def self.get_desp(n, desp_buff, html_replacer, html_replacer_for_no_tag_line)
    html_replacer = html_replacer
    if html_replacer.count > 0 && html_replacer[0].present?
      if html_replacer.include? n.name
        desp_buff += "\n"
      end
    end
    if n.name == "text"
      if html_replacer_for_no_tag_line == 1 && (html_replacer.count > 0 && html_replacer[0].present?)
        if n.parent.first_element_child != n
          if html_replacer.include? n.previous_sibling.try(:name)
            desp_buff += "\n"
          end
        end
      end
      desp_buff += n.inner_text.gsub("\n", " ") if n.inner_text.present?
      if !(html_replacer.count > 0 && html_replacer[0].present?)
        desp_buff += "\n"
      end
    end
    if n.children.present?
      n.children.each do |c|
        desp_buff = get_desp(c, desp_buff, html_replacer, html_replacer_for_no_tag_line)
      end
    end
    return desp_buff
  end


  def self.download_images(image_urls)
    image_path = "#{Rails.root}/public/images"
    Dir.mkdir image_path if !Dir.exist?(image_path)
    images = []
    image_urls.each do |image_url|
      extn = File.extname  image_url
      image_name = Digest::MD5.hexdigest(image_url) + extn
      next if File.exist? "#{image_path}/#{image_name}"
      res = RestClient.get(image_url)
      File.open("#{image_path}/#{image_name}", 'wb') { |f| f.write(res.body) }
      images << "/images/#{image_name}#{extn}"
    end
    return images
  end

  def self.download_files(file_urls)
    file_path = "#{Rails.root}/public/files"
    Dir.mkdir file_path if !Dir.exist?(file_path)
    files = []
    file_urls.each do |file_url|
      extn = File.extname  file_url
      file_name = Digest::MD5.hexdigest(file_url) + extn
      next if File.exist? "#{file_path}/#{file_name}"
      res = RestClient.get(file_url)
      File.open("#{file_path}/#{file_name}", 'wb') { |f| f.write(res.body) }
      files << "/files/#{file_name}#{extn}"
    end
    return files
  end


  def self.download_audio_videos(urls)
    file_path = "#{Rails.root}/public/audio_videos"
    Dir.mkdir file_path if !Dir.exist?(file_path)
    files = []
    urls.each do |url|
      extn = File.extname  url
      file_name = Digest::MD5.hexdigest(url) + extn
      next if File.exist? "#{file_path}/#{file_name}"
      image_res = RestClient.get(url)
      File.open("#{file_name}/#{file_name}", 'wb') { |f| f.write(image_res.body) }
      files << "/audio_videos/#{file_name}#{extn}"
    end
    return files
  end

end
