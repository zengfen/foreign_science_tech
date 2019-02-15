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

	def self.update_data_sources
		GovernmentInfo.all.each do |x|
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
				unless a.newslookup
					data_source << 'Newslookup'
				end
			end
			x.update({data_source:data_source.uniq.join(',')})
		end
	end	
end
