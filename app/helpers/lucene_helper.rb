module LuceneHelper
	def es_index_status(status)
	  span_class = ""
		case status.downcase
		when "red"
			span_class = "text-danger"
		when "yellow"
			span_class = "text-warning"
		when "green"
			span_class = "text-info"
		end
		html = "<i class=\"fa fa-circle #{span_class}\"></i><span class=\"#{span_class}\">#{status}</span>"
		return html
	end
end
