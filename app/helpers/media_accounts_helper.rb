module MediaAccountsHelper

	def try_translate_language_cn(language)
		language_hash = {"Arabic"=>"阿拉伯语", "Bahasa Indonesia"=>"印尼语", "Bahasa Melayu"=>"马来语", "Bulgarian"=>"保加利亚语", "Catalan"=>"西班牙加泰罗尼亚语", "Chinese (traditional)"=>"中文 (繁体)", "Chinese (simplified)"=>"中文 (简体)", "Czech"=>"捷克语", "Danish"=>"丹麦语", "Dutch"=>"荷兰语", "English"=>"英语", "Finnish"=>"芬兰语", "French"=>"法语", "German"=>"德语", "Hungarian"=>"匈牙利语", "Italian"=>"意大利语", "Japanese"=>"日语", "Korean"=>"韩语", "Norwegian"=>"挪威语", "Polish"=>"波兰语", "Portuguese"=>"葡萄牙语", "Russian"=>"俄语", "Slovak"=>"斯洛伐克语", "Spanish"=>"西班牙语", "Swedish"=>"瑞典语", "Thai"=>"泰语", "Turkish"=>"土耳其语", "Vietnamese"=>"越南语"} 
		language_hash.has_key?(language) ? language_hash[language] : language
	end

	def try_translate_type_cn(type)
		type_hash = {"article"=>"文章", "blog"=>"博客", "inventory"=>"清单", "picture"=>"图片", "webpage"=>"网页"}
		type_hash.has_key?(type) ? type_hash[type] : type
	end
end
