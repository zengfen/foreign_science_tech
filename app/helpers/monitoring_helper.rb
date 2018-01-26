module MonitoringHelper

	def pick_up_number(string)
		return string[/[1-9]\d*\.\d*|0\.\d*[1-9]\d*/] rescue ""
	end
end
