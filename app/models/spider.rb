# == Schema Information
#
# Table name: spiders
#
#  id                       :bigint           not null, primary key
#  spider_name              :string(255)
#  spider_type              :integer
#  network_environment      :integer          default(1)
#  proxy_support            :boolean          default(FALSE)
#  has_keyword              :boolean          default(FALSE)
#  category                 :string(255)
#  additional_function      :json
#  instruction              :string(255)
#  has_time_limit           :boolean          default(FALSE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class Spider < ApplicationRecord
  has_many :spider_tasks, dependent: :destroy

  validates :spider_name, presence: true, length: {maximum: 50},
            uniqueness: {case_sensitive: false}


  def self.status_list
    cn_hash = {0 => '未启动', 1 => '周期运行中', 2 => '已停止'}
  end

  def status_cn
    Spider.status_list[status]
  end

  def real_time_status_cn
    self.spider_tasks.order(:created_at).last.status_cn rescue '未启动'
  end


  #===========================================================


  def can_start?
    spider_task = self.spider_tasks.order(:created_at).last rescue nil
    return true if spider_task.blank?
    spider_task.can_start?
  end

  def can_stop?
    spider_task = self.spider_tasks.order(:created_at).last rescue nil
    return false if spider_task.blank?
    spider_task.can_stop?
  end

  def can_reopen?
    spider_task = self.spider_tasks.order(:created_at).last rescue nil
    return false if spider_task.blank?
    spider_task.can_reopen?
  end

  def create_spider_task(mode)
    line = {"mode" => "list", "spider_name" => self.spider_name, "body" => {}}
    keyword = Base64.encode64(line.to_json).gsub("\n", "")
    spider_task = SpiderTask.create(spider_id: self.id, full_keywords: keyword, status: SpiderTask::TypeTaskStart,task_type: mode,current_task_count: 1)
    return spider_task
  end

  # mode 启动模式  0：周期启动，1：实时启动
  def start_task(mode)
    if can_reopen?
      reopen_task
      return {type: "success",message: "实时任务启动成功"}
    end
    job_instance = TSkJobInstance.where(spider_name: self.spider_name).first
    if job_instance.blank?
      return {type: "error",message: "对应TSkJobInstance实例为空"}
    end
    # 周期任务直接可以执行，实时任务需判断状态后执行
    if mode == SpiderTask::RealTimeTask
      return {type: "error",message: "实时任务正在执行中"} unless can_start?
    end
    log_mode = SpiderTask.t_log_spider_mode[mode]
    # 创建一条爬虫日志数据
    TLogSpider.create({spider_name: self.spider_name, start_time: Time.now, mode: log_mode})
    spider_task = self.create_spider_task(mode)
    # 创建子任务 缓存子任务
    spider_task.create_subtasks
    # 检查任务状态，处理任务
    # spider_task.process_status
    return {type: "success",message: "实时任务启动成功"}

  end


  # 暂停任务
  def stop_task(mode)
    return {type: "error",message: "周期生成的单次任务正在执行中"} unless can_stop?
    spider_task = self.spider_tasks.order(:created_at).last rescue nil
    spider_task.update(status: SpiderTask::TypeTaskStop)
    # # 检查任务状态，处理任务
    spider_task.process_status
    return {type: "success",message: "实时任务暂停成功"}
  end

  # 重启任务
  def reopen_task
    return unless can_reopen?
    spider_task = self.spider_tasks.order(:created_at).last rescue nil
    spider_task.update(status: SpiderTask::TypeTaskReopen)
    # 检查任务状态，处理任务
    spider_task.process_status
    # self.update(real_time_status: SpiderTask::TypeTaskComplete)
  end


  # # 周期任务，调用此方法生成cron定时任务
  # def init_task_job
  #   # 周期任务审核通过后且是有效数据，才能创建crontab任务
  #   # return if self.status_before_type_cast != 4 || self.is_deleted
  #   cron = Sidekiq::Cron::Job.find self.job_name
  #   if cron.blank?
  #     time = "#{self.cron_minutes} #{self.cron_hour} * * * Asia/Shanghai"
  #     cron = Sidekiq::Cron::Job.new(name: self.job_name, cron: time, class: 'ProcessStatusJob', args: {spider_name: self.spider_name}) if cron.blank?
  #     if cron.valid?
  #       cron.save
  #     else
  #       Rails.logger.info cron.errors
  #     end
  #   else
  #     time = "*/10 * * * * Asia/Shanghai"
  #     cron.cron = time
  #     cron.save
  #   end
  # end
  #
  # # 初始化所有任务
  # def self.init_all_tasks
  #   self.all.each do |x|
  #     x.init_task_job
  #   end
  # end
  #
  #
  # # cron任务名称
  # def job_name
  #   "ProcessStatusJob-#{self.spider_name}"
  # end


  def self.update_complete(log_spider_id)
    spider_name = TLogSpider.find(log_spider_id).spider_name
    self.where(spider_name: spider_name).first.update(run_type: TypeTaskCompleted)

  end

end
