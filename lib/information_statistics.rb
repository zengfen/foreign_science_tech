class InformationStatistics
  attr_accessor :last_days

  def initialize(opt={})
  	@last_days = opt[:last_days] || 15
  end

	def renew_statistics
		$redis.del(redis_key)
		
		@last_days.times.each do |i|
			i += 1
			start_time = (Time.now - i.day).to_i
			end_time = (Time.now - i.day + 1.day).to_i
			pids = ArchonNewsTag.where("created_at >= ?",start_time).where("created_at <= ?",end_time).pluck('pid')
			
			ArchonNews.where({id:pids}).each do |x|
				source_url = x.source_url
				domain = source_url.split('://').last.split('/').first rescue ''
				domain = domain.gsub('www.','') rescue ''
				unless domain.blank?
					created_time = Time.at(x.created_time).strftime("%F")
					day_key = (Time.now.to_i - Time.parse(created_time).to_i)/86400
					domain_key = "#{domain}_#{day_key}"
					domain_key1 = "#{x.site}_#{day_key}"
					domain_key2 = "#{x.site_url}_#{day_key}"
					$redis.hincrby(redis_key,domain_key,1)
					if domain_key1 != domain_key
						$redis.hincrby(redis_key,domain_key1,1)
					end

					if !domain_key2.include?('/') && domain_key2 != domain_key && domain_key2 != domain_key1
						$redis.hincrby(redis_key,domain_key2,1)
					end
				end
			end			
		end

	end

	def redis_key
		return "archon_center_info_statistics"
	end
end