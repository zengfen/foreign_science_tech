class InformationStatistics
  attr_accessor :last_days

  def initialize(opt={})
  	@last_days = opt[:last_days] || 16
  end

	def renew_statistics
		$redis.del(redis_key)
		$redis.set(redis_switch_key,1) # 更新中
		now_time = Time.now
		begin
			@last_days.times.each do |i|
				i += 1
				start_time = (now_time - i.day).to_i
				end_time = (now_time - i.day + 1.day).to_i
				pids = ArchonNewsTag.where("created_at > ?",start_time).where("created_at <= ?",end_time).pluck('pid')
				
				ArchonNews.where({id:pids}).each do |x|
					source_url = x.source_url
					domain = source_url.split('://').last.split('/').first rescue ''
					domain = domain.gsub('www.','') rescue ''
					unless domain.blank?
						created_time = Time.at(x.created_time).strftime("%F")
						# day_key = (Time.now.to_i - Time.parse(created_time).to_i)/86400
						day_key = created_time
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
		rescue Exception => e
			$redis.set(redis_switch_key,3)
		end
		$redis.set(redis_switch_key,2)
	end

	# 更新当天的新闻量统计
	def renew_statistics_today
		$redis.set(redis_switch_key1,1)
		begin
			all_fields = $redis.hkeys(redis_key) || []
			all_fields.each do |x|
				if x.include?("#{Time.now.strftime("%F")}")
					$redis.hdel(redis_key,x)
				end
			end
			ArchonNews.where("created_time >=?",Time.now.beginning_of_day.to_i).each do |x|
				created_time = Time.at(x.created_time).strftime("%F")
				day_key = created_time
				domain_key2 = "#{x.site_url}_#{day_key}"
				$redis.hincrby(redis_key,domain_key2,1)
			end			
		rescue Exception => e
			$redis.set(redis_switch_key1,3)
		end
		$redis.set(redis_switch_key1,2)
	end

	def redis_key
		return "archon_center_info_statistics"
	end

	def redis_switch_key
		return "archon_center_info_statistics_switch"
	end

	def redis_switch_key1
		return "archon_center_info_statistics_switch_1"
	end

	def self.start_renew
		$redis.set(self.new.redis_switch_key,1)
	end

	def self.switch
		return $redis.get(self.new.redis_switch_key).to_i rescue 0
	end

	def self.start_renew1
		$redis.set(self.new.redis_switch_key1,1)
	end

	def self.switch1
		return $redis.get(self.new.redis_switch_key1).to_i rescue 0
	end
end