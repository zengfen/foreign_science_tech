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
			'Dowjones',
			'人工爬虫'
		]
	end

	def self.levels
		return {
			0 => '重点',
			1 => '一级',
			2 => '二级',
			3 => '三级',
			100 => '未分级',
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
			'太极重点媒体'=> ["indiatimes.com", "reuters.com", "forbes.com", "indianexpress.com", "thestar.com.my", "usatoday.com", "theguardian.com", "bloomberg.com", "independent.co.uk", "go.com", "cnn.com", "sputniknews.com", "scmp.com", "latimes.com", "newsweek.com", "jpost.com", "nytimes.com", "foxnews.com", "japantimes.co.jp", "timesofisrael.com", "rt.com", "upi.com", "voanews.com", "wsj.com", "bangkokpost.com", "bbc.com", "bangkokpost.com", "indianexpress.com", "fortune.com", "dawn.com", "afp.com", "time.com", "smh.com.au", "vancouversun.com", "arabnews.com", "straitstimes.com", "thesun.co.uk", "economist.com", "manilatimes.net", "thejakartapost.com", "arabnews.com", "mb.com.ph", "the-japan-news.com", "washingtonpost.com", "xinhuanet.com", "bloomberg.com","chinadaily.com.cn","people.cn","xinhuanet.com","cgtn.com","globaltimes.cn"],
			'外文局重点' => ["sputniknews.cn","tass.com","handelsblatt.com","tagesspiegel.de"],
			'saas测试媒体' =>  ["aljazeera.com", "ansa.it", "arabnews.com", "bangkokpost.com", "barrons.com", "bg.net", "bernama.com", "canberratimes.com.au", "chicagotribune.com", "chosun.com", "cnn.com", "cna.org.cy", "dailymail.co.uk", "dawn.com", "donga.com", "dowjones.com", "dpa.com", "euobserver.com", "forbes.com", "ghananewsagency.org", "gulf-daily-news.com", "hindustantimes.com", "intoday.in", "itar-tass.com", "jiji.com", "petra.gov.jo", "kuwaittimes.net", "kyodonews.jp", "mb.com.ph", "nst.com.my", "newsweek.com", "pna.gov.ph", "ptinews.com", "skrin.ru", "scmp.com", "spiegel.de", "sputniknews.com", "tasr.sk", "ap.org", "theaustralian.com.au", "afr.com", "csmonitor.com", "economist.com", "theglobeandmail.com", "theguardian.com", "thehindu.com", "independent.co.uk", "irishtimes.com", "thejakartapost.com", "jpost.com", "nytimes.com", "nzherald.co.nz", "thesaigontimes.vn", "saudigazette.com.sa", "straitstimes.com", "timeslive.co.za", "smh.com.au", "timesofisrael.com", "thetimes.co.uk", "thestar.com", "wsj.com", "washingtonpost.com", "thewest.com.au", "indiatimes.com", "uza.uz", "vietnamnews.vn", "dw.com", "voachinese.com", "bbc.com","guanchajiabao.com"]
		}
	end

	def self.update_data_sources
		MediaInfo.all.each do |x|
			a = DomainDataSource.where({domain:x.domain}).first
			data_source = x.data_source.split(',') rescue []
			unless a.blank?
				rsses = JSON.parse(a.rss_site) rescue []
				rsses.each do |rss|
					if rss.include?('news.google')
						data_source << 'Googlenrss'
					else
						data_source << 'Rss'
					end
				end
				unless a.newslookup.blank?
					data_source << 'Newslookup'
				end
			end
			x.update({data_source:data_source.uniq.join(',')})
		end
	end

	def self.update_levels
		MediaInfo.all.each do |x|
			levels = x.level.split(",")
			if levels.include?("100") && levels.size > 1
				levels.delete("100")
				x.update({level:levels.join(',')})
			end
		end
	end

end
