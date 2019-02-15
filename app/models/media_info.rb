class MediaInfo < ApplicationRecord

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
			0 => '重点',
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

	def self.custom_domains
		return {
			'太极重点媒体'=> ["indiatimes.com", "reuters.com", "forbes.com", "indianexpress.com", "thestar.com.my", "usatoday.com", "theguardian.com", "bloomberg.com", "independent.co.uk", "go.com", "cnn.com", "sputniknews.com", "scmp.com", "latimes.com", "newsweek.com", "jpost.com", "nytimes.com", "foxnews.com", "japantimes.co.jp", "timesofisrael.com", "rt.com", "upi.com", "voanews.com", "wsj.com", "bangkokpost.com", "bbc.com", "bangkokpost.com", "indianexpress.com", "fortune.com", "dawn.com", "afp.com", "time.com", "smh.com.au", "vancouversun.com", "arabnews.com", "straitstimes.com", "thesun.co.uk", "economist.com", "manilatimes.net", "thejakartapost.com", "arabnews.com", "mb.com.ph", "the-japan-news.com", "washingtonpost.com", "xinhuanet.com", "bloomberg.com"],
			'外文局重点' => ["sputniknews.cn","tass.com","handelsblatt.com","tagesspiegel.de"],
		}
	end

end
