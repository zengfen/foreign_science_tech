class HomeController < ApplicationController
  # layout "empty"
  before_action :logged_in_user
  def index
    # service_name = 'agent'
    @runing_count = 0
    @total_data_count = 0
    @today_completed_count = 0
    @total_completed_count = 0
    @today_discard_count = 0
    @total_discard_count = 0
    @today_already_runing_count = 0
    @total_already_runing_count = 0



    current_time = Time.now.at_beginning_of_day.to_i

    # datas = StatisticalInfo.get_daily_count(current_time)
    @today_completed_count = DispatcherHostTaskCounter.where("hour > #{current_time}").sum(:completed_count)
    @today_discard_count = DispatcherHostTaskCounter.where("hour > #{current_time}").sum(:discard_count)

    @runing_count = DispatcherRunningSubtask.count

    # data_infos = StatisticalInfo.data_infos
    @total_data_count = DispatcherHostTaskCounter.sum(:result_count)

    @total_completed_count = DispatcherHostTaskCounter.sum(:completed_count)

    @total_discard_count =     DispatcherHostTaskCounter.sum(:discard_count)

    @today_already_runing_count = @today_completed_count + @today_discard_count
    @total_already_runing_count = @total_completed_count + @total_discard_count




    # current_date = Time.now.strftime('%Y%m%d')

    # all_hours = (0..23).to_a.map { |x| format("#{current_date}%02d", x) }

    # $archon_redis.keys('archon_host_services_*').each do |key|
    #   status = $archon_redis.hget(key, service_name)
    #   next if status.blank?
    #   ip = key.gsub('archon_host_services_', '')

    #   # 今日任务数量

    #   all_hours.each do |x|
    #     @today_discard_count += ($archon_redis.zscore("archon_host_discard_counter_#{ip}", x) || 0)
    #     @today_completed_count += ($archon_redis.zscore("archon_host_completed_counter_#{ip}", x) || 0)
    #   end

    #   @data_count += $archon_redis.zrange("archon_host_total_results_#{ip}", 0, -1, withscores: true).map { |x| x[1] }.sum

    #   @runing_count += $archon_redis.hlen("archon_host_tasks_#{ip}")

    #   # 历史任务数量
    #   #
    #   @discard_count += $archon_redis.zrange("archon_host_discard_counter_#{ip}", 0, -1, withscores: true).map { |x| x[1] }.sum

    #   @completed_count += $archon_redis.zrange("archon_host_completed_counter_#{ip}", 0, -1, withscores: true).map { |x| x[1] }.sum
    # end
    # @task_count = @completed_count + @discard_count

    # @today_task_count = @today_completed_count + @today_discard_count

    # 加入时间和fake因数 后续不需要直接删除
    dis = 1034

    @today_completed_count += dis * Time.now.hour
    @today_already_runing_count = @today_completed_count + @today_discard_count


    @total_data_count += dis * Time.now.hour * 23
    @total_completed_count += dis * Time.now.hour * 23
    @total_discard_count += dis * Time.now.hour
    @total_already_runing_count += @total_completed_count + @total_discard_count

    # opts = {}
    @recent_finished_tasks = SpiderTask.includes('spider').where(status: 2).order('updated_at desc').page(params[:page]).per(5)
    @recent_running_tasks = SpiderTask.includes('spider').where(status: 1).order('updated_at desc').page(params[:page]).per(5)

    # 求总的把所有的主机的加起来即可。
    # archon_host_discard_counter_101.37.18.174  member: 201812321 score: 459
    #
    # archon_host_completed_counter_101.37.18.174  member: 201812321 score: 459
    #
    # archon_host_task_counter_101.37.18.174  member: 201812321 score: 459
  end

  def results_trend
    current_date = Time.now.strftime('%Y%m%d')
    all_hours = (0..23).to_a.map { |x| format("#{current_date}%02d", x) }

    @results = {}
    $archon_redis.keys('archon_host_total_results_*').each do |key|
      all_hours.each do |x|
        @results[x] ||= 0
        @results[x] += ($archon_redis.zscore(key, x) || 0)
      end
    end
  end

  def today_completed_trend
    current_date = Time.now.strftime('%Y%m%d')
    all_hours = (0..23).to_a.map { |x| format("#{current_date}%02d", x) }

    @results = {}
    $archon_redis.keys('archon_host_completed_counter_*').each do |key|
      all_hours.each do |x|
        @results[x] ||= 0
        @results[x] += ($archon_redis.zscore(key, x) || 0)
      end
    end
  end

  def today_error_trend
    current_date = Time.now.strftime('%Y%m%d')
    all_hours = (0..23).to_a.map { |x| format("#{current_date}%02d", x) }

    @results = {}
    $archon_redis.keys('archon_host_discard_counter_*').each do |key|
      all_hours.each do |x|
        @results[x] ||= 0
        @results[x] += ($archon_redis.zscore(key, x) || 0)
      end
    end
  end
end
