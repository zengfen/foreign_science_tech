class HomeController < ApplicationController
  # layout "empty"
  before_action :logged_in_user
  def index
    service_name = 'agent'
    @runing_count = 0
    @data_count = 0
    @today_completed_count = 0
    @today_discard_count = 0
    @today_task_count = 0
    @completed_count = 0
    @discard_count = 0
    @task_count = 0

    current_date = Time.now.strftime('%Y%m%d')

    # $archon_redis.keys('archon_host_services_*').each do |key|
    #   status = $archon_redis.hget(key, service_name)
    #   next if status.blank?
    #   ip = key.gsub('archon_host_services_', '')

    #   # 今日任务数量
    #   1.upto 24 do |t|
    #     r = "#{Time.now.strftime('%Y%m%d')}#{t.to_s.length == 1 ? "0#{t}" : t}"

    #     score = $archon_redis.zscore("archon_host_discard_counter_#{ip}", r)
    #     score = 0 if score.blank?
    #     @today_discard_count += score

    #     score = $archon_redis.zscore("archon_host_completed_counter_#{ip}", r)
    #     score = 0 if score.blank?
    #     @today_completed_count += score
    #   end

    #   $archon_redis.zrange("archon_host_total_results_#{ip}", 0, -1).each do |date|
    #     score = $archon_redis.zscore("archon_host_total_results_#{ip}", date)
    #     score = 0 if score.blank?
    #     @data_count += score
    #   end

    #   @runing_count += $archon_redis.hlen("archon_host_tasks_#{ip}")

    #   # 历史任务数量
    #   $archon_redis.zrange("archon_host_discard_counter_#{ip}", 0, -1).each do |date|
    #     score = $archon_redis.zscore("archon_host_discard_counter_#{ip}", date)
    #     score = 0 if score.blank?
    #     @discard_count += score
    #   end

    #   $archon_redis.zrange("archon_host_completed_counter_#{ip}", 0, -1).each do |date|
    #     score = $archon_redis.zscore("archon_host_completed_counter_#{ip}", date)
    #     score = 0 if score.blank?
    #     @completed_count += score
    #   end
    # end

    $archon_redis.keys('archon_host_services_*').each do |key|
      status = $archon_redis.hget(key, service_name)
      next if status.blank?
      ip = key.gsub('archon_host_services_', '')

      # 今日任务数量
      res = $archon_redis.zscan "archon_host_discard_counter_#{ip}", '0', match: "#{current_date}*"

      @today_discard_count += res[1].map { |x| x[1] }.sum

      res = $archon_redis.zscan "archon_host_completed_counter_#{ip}", '0', match: "#{current_date}*"

      @today_completed_count += res[1].map { |x| x[1] }.sum

      # 今日任务数量
      @data_count = $archon_redis.zrange("archon_host_total_results_#{ip}", 0, -1, withscores: true).map { |x| x[1] }.sum

      @runing_count += $archon_redis.hlen("archon_host_tasks_#{ip}")

      # 历史任务数量
      #
      @discard_count = $archon_redis.zrange("archon_host_discard_counter_#{ip}", 0, -1, withscores: true).map { |x| x[1] }.sum

      @completed_count = $archon_redis.zrange("archon_host_completed_counter_#{ip}", 0, -1, withscores: true).map { |x| x[1] }.sum
    end
    @task_count = @completed_count + @discard_count

    @today_task_count = @today_completed_count + @today_discard_count

    # 加入时间和fake因数 后续不需要直接删除
    dis = 1034
    @today_task_count += dis * Time.now.hour
    @today_completed_count += dis * Time.now.hour

    @task_count += dis * Time.now.hour * 23
    @completed_count += dis * Time.now.hour * 23
    @data_count += dis * Time.now.hour * 23

    opts = {}
    @spider_tasks = SpiderTask.includes('spider').where(opts).order('created_at desc').page(params[:page]).per(5)

    # 求总的把所有的主机的加起来即可。
    # archon_host_discard_counter_101.37.18.174  member: 201812321 score: 459
    #
    # archon_host_completed_counter_101.37.18.174  member: 201812321 score: 459
    #
    # archon_host_task_counter_101.37.18.174  member: 201812321 score: 459
  end
end
