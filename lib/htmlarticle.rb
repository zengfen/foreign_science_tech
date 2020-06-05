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

  # 图片下载
  def self.download_images(image_urls)
    path = "#{Rails.root}/public/images"
    Dir.mkdir path if !Dir.exist?(path)
    files = []
    image_urls.each do |url|
      res = RestClient.get(url)
      content_type = res.headers[:content_type]
      extn = Rack::Mime::MIME_TYPES.invert[content_type]
      name = Digest::MD5.hexdigest(url) + extn
      if File.exist? "#{path}/#{name}"
        files << "/images/#{name}"
        next
      end
      File.open("#{path}/#{name}", 'wb') { |f| f.write(res.body) }
      files << "/images/#{name}"
    end
    return files
  end

  # 文件下载
  def self.download_files(file_urls)
    path = "#{Rails.root}/files"
    Dir.mkdir path if !Dir.exist?(path)
    files = []
    file_urls.each do |url|
      res = RestClient.get(url)
      content_type = res.headers[:content_type]
      extn = Rack::Mime::MIME_TYPES.invert[content_type]
      name = Digest::MD5.hexdigest(url) + extn
      if File.exist? "#{path}/#{name}"
        files << "/files/#{name}"
        next
      end
      File.open("#{path}/#{name}", 'wb') { |f| f.write(res.body) }
      files << "/files/#{name}"
    end
    return files
  end


  # 音视频下载
  def self.download_medias(urls)
    path = "#{Rails.root}/medias"
    Dir.mkdir path if !Dir.exist?(path)
    files = []
    urls.each do |url|
      res = RestClient.get(url)
      content_type = res.headers[:content_type]
      extn = Rack::Mime::MIME_TYPES.invert[content_type]
      name = Digest::MD5.hexdigest(url) + extn
      if File.exist? "#{path}/#{name}"
        files << "/medias/#{name}"
        next
      end
      File.open("#{path}/#{name}", 'wb') { |f| f.write(res.body) }
      files << "/medias/#{name}"
    end
    return files
  end

end
