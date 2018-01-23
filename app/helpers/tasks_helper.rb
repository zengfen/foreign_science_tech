module TasksHelper
	def status_html(obj)
		span_class = ""
		case obj.status
		when 0
			span_class = "label-info"
		when 1
			span_class = "label-primary"
		when 2
			span_class = "label-success"
		when 3
			span_class = "label-warning"
		end
		html = "<span class=\"label #{span_class}\">#{obj.status_cn}</span>"
		return html
	end
end