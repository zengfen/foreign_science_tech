module SocialAccountsHelper
def social_account_type_i(account_type)
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

def social_account_category_i(social_account)
		i_class = ""
		case social_account.account_category
		when 0
			i_class = "fa-users"
		when 1
			i_class = "fa-user"
		end
		html = "<i class=\"fa #{i_class}\" title=\"#{social_account.account_category_cn}\"></i>"
		return html
end
end
