module SpiderTasksHelper
	def status_html(spider_task)
		span_class = ""
		case spider_task.status
		when 0
			span_class = "label-info"
		when 1
			span_class = "label-warning"
		when 2
			span_class = "label-primary"
		end
		html = "<span class=\"label #{span_class}\">#{spider_task.status_cn}</span>"
		return html
	end
end
