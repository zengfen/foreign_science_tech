class GovernmentInfo < ApplicationRecord

	def self.data_sources
		return [
			'Webhose',
			'Newspaper',
			'Googlenews',
			'Googlenrss',
			'Rss',
			'Newslookup',			
			'GDELT',
			'人工爬虫'
		]
	end

	def self.levels
		return {
			1 => '一级',
			2 => '二级',
			3 => '三级',
		}
	end

	def self.hav_infos
		return {
			1 => '有',
			0 => '无',
		}
	end
end
