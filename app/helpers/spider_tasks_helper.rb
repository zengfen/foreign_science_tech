module SpiderTasksHelper
  def status_html(obj)
    span_class = ""
    case obj.status
    when 0
      span_class = "text-muted"
    when 1
      span_class = "text-warning"
    when 2
      span_class = "text-info"
    when 3
      span_class = "text-success"
    when 4
      span_class = "text-warning"
    when 5
      span_class = "text-warning"
    end
    html = "<span class=\"#{span_class}\">#{obj.status_cn}</span>"
    return html
  end

  def status_html_new(obj)
    span_class = ""
    case obj.status
    when 0
      span_class = "text-muted"
    when 1
      span_class = "text-success"
    when 2
      span_class = "text-warning"
    end
    html = "<span class=\"#{span_class}\">#{obj.status_cn}</span>"
    return html
  end

  def status_text(obj)
    return obj.status_cn
  end
end
