class MediaInfo < ApplicationRecord

	def self.data_sources
		return [
			'Webhose',
			'Newspaper',
			'Googlenews',
			'人工爬虫'
		]
	end

	def self.levels
		return [0,1,2,3]
	end
end
