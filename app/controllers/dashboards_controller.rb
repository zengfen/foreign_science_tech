class DashboardsController < ApplicationController
  before_action :logged_in_user

  def index
    @total_data_count = TData.count
    @today_count = TData.during(Date.today,Date.today).count
    @last_week_count = TData.during(Date.today.at_beginning_of_week,Date.today).count
    @last_month_count = TData.during(Date.today.at_beginning_of_month,Date.today).count
    # 每天采集数据量 可以每天统计 当天的需要每两小时更新一次
    # 网站每天发布的新闻 要每两小时统计一次
    # 每天总的发布数量

    # 计算每个站点每天发布的新闻
    # 日期 2020-01-01 a 发布量3条  采集量4条
    # 2020-01-02 a 4条
    # 2020-01-01 b 4条
    # 2020-01-02 b 5条

    # 统计每个作者每天发布的新闻量
    # 作者 a  发布量 2条


    # 本地图片未展示 日期选择范围是多长
    # 问题 采集量是按照新闻发布时间con_tim统计还是采集时间统计data_time  若con_tim 则需要更新
    # 爬虫统计和网站统计不是相同的结果吗
    # 每日采集数据量趋势图
    @spider_every_day = [] # 每日采集数据量趋势图
    @spider_task_count = [] # 每日采集任务量趋势图
    @spider_success_task = [] # 每日成功采集任务量趋势图
    @spider_data_count = [] # 网站发布统计 按日期
    @author_count = [] # 作者发布统计
    @spider_name_count = [] # 爬虫采集统计 按站点
    spider_every_day = TData.group("date(data_time)").select("date(data_time) date,count(*) count").map { |x| {name: x.date.strftime("%F"), value: x.count} }
    spider_data_count = TData.group("date(con_time)").select("date(con_time) date,count(*) count").map { |x| {name: x.date.strftime("%F"), value: x.count} }
    @spider_name_count = TData.group("website_name").select("website_name,count(*) count").map { |x| {name: x.website_name, value: x.count} }

    # 多个作者的情况
    @author_count = TData.group("con_author").select("con_author,count(*) count").map { |x| {name: x.con_author, value: x.count} }

    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : (Date.today - 1.month)
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today

    spider_task_count = SpiderTask.group("date(created_at)").select("date(created_at) date,sum(current_task_count) task_count,sum(current_success_count) success_count").map { |x| {name: x.date.strftime("%F"), task_count: x.task_count, success_count: x.success_count} }
    (start_date..end_date).each do |date|
      date = date.strftime("%F")
      data = spider_task_count.find { |x| x[:name] == date }
      if data.blank?
        data = {name: date, value: 0}
        @spider_task_count << data
        @spider_success_task << data
      else
        @spider_task_count << {name: data[:name], value: data[:task_count]}
        @spider_success_task << {name: data[:name], value: data[:success_count]}
      end
      one_spider_every_day = spider_every_day.find { |x| x[:name] == date }
      if one_spider_every_day.blank?
        @spider_every_day << data
      else
        @spider_every_day << one_spider_every_day
      end
      one_spider_data_count = spider_data_count.find { |x| x[:name] == date }
      if one_spider_data_count.blank?
        @spider_data_count << data
      else
        @spider_data_count << one_spider_data_count
      end
    end


  end
end