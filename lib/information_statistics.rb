class InformationStatistics
  attr_accessor :last_days

  def initialize(opt={})
  	@last_days = opt[:last_days] || 15
  end

	def renew_statistics
		created_at = (Time.now - @last_days.day).to_i
		pids = ArchonNewsTag.where("created_at >= ?",created_at).pluck('pid')
		
		$redis.del(redis_key)
		
		ArchonNews.where({id:pids}).find_each do |x|
			source_url = x.source_url
			domain = source_url.split('://').last.split('/').first rescue ''
			domain = domain.gsub('www.','') rescue ''
			unless domain.blank?
				created_time = Time.at(x.created_time).strftime("%F")
				day_key = (Time.now.to_i - Time.parse(created_time).to_i)/86400
				domain_key = "#{domain}_#{day_key}"
				$redis.hincrby(redis_key,domain_key,1)
			end
		end
	end

	def redis_key
		return "archon_center_info_statistics"
	end
end