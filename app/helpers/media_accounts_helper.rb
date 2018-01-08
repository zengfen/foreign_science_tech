module MediaAccountsHelper
def media_account_type_i(account_type)
		i_class = ""
		case account_type
		when "twitter"
			i_class = "fa-twitter"
		when "facebook"
			i_class = "fa-facebook"
		when "youtube"
			i_class = "fa-youtube"
		when "linkedin"
			i_class = "fa-linkedin"
		end
		html = "<i class=\"fa #{i_class}\" title=\"#{account_type}\"></i>"
		return html
end
end
