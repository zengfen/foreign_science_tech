# == Schema Information
#
# Table name: statistical_infos
#
#  id             :integer          not null, primary key
#  host_ip        :string
#  info_type      :integer
#  count          :integer
#  recording_time :datetime
#  hour_field     :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class StatisticalInfo < ApplicationRecord
  scope :discard_tasks, -> { where(info_type: 1) }
  scope :completed_tasks, -> { where(info_type: 2) }
  scope :runing_tasks, -> { where(info_type: 3) }
  scope :data_infos, -> { where(info_type: 4) }

  def self.info_types
    {
      1=>"discard_count",#失败任务
      2=>"completed_count",#成功任务
      3=>"runing_count",#执行中任务
      4=>"data_count"#数据量
    }
  end

  def self.get_ip_list
     service_name = 'agent'
     ips = []

     $archon_redis.keys('archon_host_services_*').each do |key|
      status = $archon_redis.hget(key, service_name)
      next if status.blank?
      ips << key.gsub('archon_host_services_', '')
      end

      return ips
  end

  def self.refresh_data
     si = StatisticalInfo.last
     try_init_history! if si.blank?

     service_name = 'agent'
     time  = Time.now

     $archon_redis.keys('archon_host_services_*').each do |key|
      status = $archon_redis.hget(key, service_name)
      next if status.blank?
      ip = key.gsub('archon_host_services_', '')
      refresh_one_data(ip,time)
      end
  end

  def self.try_init_history!
     time  = Time.now.strftime('%Y%m%d%H')
     ips  = self.get_ip_list
     times = [time]

     ips.each do |ip|
       times << $archon_redis.zrange("archon_host_total_results_#{ip}", 0, -1, withscores: false).sort.first || time
       times << $archon_redis.zrange("archon_host_completed_counter_#{ip}", 0, -1, withscores: false).sort.first || time
       times << $archon_redis.zrange("archon_host_discard_counter_#{ip}", 0, -1, withscores: false).sort.first || time
     end

     first_date = Time.parse(times.sort.first).to_date

     ips.each do |ip|
         (first_date..Date.today).each do |x|
           (0..23).each do |num|
            time = format("#{x.strftime('%Y%m%d')}%02d", num).to_time
            refresh_one_data(ip,time)
           end
          end
      end
     
  end

  def self.refresh_one_data(ip,time)
    hour_info = time.strftime('%Y%m%d%H')
    data = {}
    data["discard_count"] = $archon_redis.zscore("archon_host_discard_counter_#{ip}", hour_info) || 0
    data["completed_count"] = $archon_redis.zscore("archon_host_completed_counter_#{ip}", hour_info) || 0
    data["data_count"] = $archon_redis.zscore("archon_host_total_results_#{ip}", hour_info) || 0
    data["runing_count"] = $archon_redis.hlen("archon_host_tasks_#{ip}")

    StatisticalInfo.transaction do
      info_types.each do |info_type,value|
        si = StatisticalInfo.find_or_initialize_by(:host_ip=>ip,:info_type=>info_type,:hour_field=>hour_info)
        si.update!(:recording_time=>time,:count=>data[value])
      end
    end 
  end

  def self.get_daily_count(time)
    infos = {}
    datas = StatisticalInfo.where(:recording_time=>time.beginning_of_day..time.end_of_day)
    
    StatisticalInfo.info_types.each do |info_type,value|
      infos[value] = datas.collect{|x| (x.info_type == info_type) ? x.count : 0}.sum||0
    end

    return infos
  end

end
