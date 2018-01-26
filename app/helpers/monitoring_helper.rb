module MonitoringHelper

	def pick_up_number(string)
		float_regular = /[1-9]\d*\.\d*|0\.\d*[1-9]\d*/
		int_regular = /[1-9]\d*/
		res = ""
		begin
			if string.match(float_regular)
			 res =  string[float_regular] 
			elsif string.match(int_regular)
			 res =  string[int_regular]
			end
		rescue
		end
		return res
	end
end
