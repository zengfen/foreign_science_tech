module SpidersHelper
	def format_additional_function(additional_function)
		text = additional_function.collect{|x| x.collect{|k,v| "#{k}:#{v}"}}.join(',') rescue ""
		return text
	end
end