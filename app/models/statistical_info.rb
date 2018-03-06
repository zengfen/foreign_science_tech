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
      4=>"data_count",#数据量
      5=>"receiver_count",#写入kafka数据量
      6=>"loader_consumer_count",#kafka消费数量
      7=>"loader_load_count"#写入ES数量
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

     time  = Time.now
     ips  = get_ip_list

     ips.each do |ip|
        refresh_one_data(ip,time)
      end
      
      #更新写入kafka数据量
      receiver_ips =  $archon_redis.hkeys('archon_receiver_errors')
      receiver_ips.each do |ip|
        refresh_one_receiver_data(ip,time)
      end
      #更新kafka消费数量和写入ES数量
      loader_ips = $archon_redis.hkeys('archon_loader_consume_errors')
      loader_ips.each do |ip|
        refresh_one_loader_consume_data(ip,time)
      end
  end

  def self.try_init_history!
     time  = Time.now.strftime('%Y%m%d%H')
     ips  = get_ip_list
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
      #更新写入kafka数据量及kafka消费数量、写入ES数量
      times = [time]
      receiver_ips =  $archon_redis.hkeys('archon_receiver_errors')
      receiver_ips.each do |ip|
        times << $archon_redis.zrange("archon_receiver_#{ip}_count", 0, -1, withscores: false).sort.first || time
      end


      loader_ips = $archon_redis.hkeys('archon_loader_consume_errors')
      loader_ips.each do |ip|
        times << $archon_redis.zrange("archon_loader_#{ip}_consumer_count", 0, -1, withscores: false).sort.first || time
        times << $archon_redis.zrange("archon_loader_#{ip}_load_count", 0, -1, withscores: false).sort.first || time
      end

      first_date = Time.parse(times.sort.first).to_date

      (first_date..Date.today).each do |x|
           (0..23).each do |num|
            time = format("#{x.strftime('%Y%m%d')}%02d", num).to_time
            
            receiver_ips.each do |ip|
              refresh_one_receiver_data(ip,time)
            end

            loader_ips.each do |ip|
              refresh_one_loader_consume_data(ip,time)
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
      info_types.first(4).each do |info_type,value|
        si = StatisticalInfo.find_or_initialize_by(:host_ip=>ip,:info_type=>info_type,:hour_field=>hour_info)
        si.update!(:recording_time=>time,:count=>data[value])
      end
    end 

  end

  def self.refresh_one_receiver_data(ip,time)
    hour_info = time.strftime('%Y%m%d%H')

    key = "archon_receiver_#{ip}_count"
    count = $archon_redis.zscore(key, hour_info) || 0

    si = StatisticalInfo.find_or_initialize_by(:host_ip=>ip,:info_type=>5,:hour_field=>hour_info)
    si.update!(:recording_time=>time,:count=>count)
  end

  def self.refresh_one_loader_consume_data(ip,time)
      hour_info = time.strftime('%Y%m%d%H')

      key = "archon_loader_#{ip}_consumer_count"
      count = $archon_redis.zscore(key, hour_info) || 0

      si = StatisticalInfo.find_or_initialize_by(:host_ip=>ip,:info_type=>6,:hour_field=>hour_info)
      si.update!(:recording_time=>time,:count=>count)

      key = "archon_loader_#{ip}_load_count"
      count = $archon_redis.zscore(key, hour_info) || 0

      si = StatisticalInfo.find_or_initialize_by(:host_ip=>ip,:info_type=>7,:hour_field=>hour_info)
      si.update!(:recording_time=>time,:count=>count)
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
