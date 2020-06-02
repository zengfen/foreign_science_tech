class TSkJobInstance < CommonBase
  self.table_name = "t_sk_job_instance"

  # 是否需要立即执行
  # 今天没有执行过周期任务，且周期时间改为比当前时间早，则需要立即执行周期任务
  def need_enque!
    spider  = Spider.where(spider_name:self.spider_name).first
    last_execute_time = spider.spider_tasks.where("created_at >= ?",Date.today).order(:created_at).last.created_at.to_i rescue nil
    return true if last_execute_time.blank?
    cron_time = Time.parse("#{self.cron_hour}:#{self.cron_minutes}").to_i rescue nil
    if last_execute_time < Date.today.to_time.to_i && cron_time < last_execute_time
      return true
    else
      return false
    end
  end

  # 周期任务，调用此方法生成或更新cron定时任务
  def init_instance_job
    # 周期任务审核通过后且是有效数据，才能创建crontab任务
    # return if self.status_before_type_cast != 4 || self.is_deleted
    cron = Sidekiq::Cron::Job.find self.job_name
    if cron.blank?
      # time = "#{self.cron_minutes} #{self.cron_hour} * * * Asia/Shanghai"
      time = "*/5 * * * * Asia/Shanghai"
      cron = Sidekiq::Cron::Job.new(name: self.job_name, cron: time, class: 'TSkJobInstancesJob', args: {spider_name: self.spider_name}) if cron.blank?
      if cron.valid?
        cron.save
        # cron.enque!     # 立即调用（执行）
      else
        Rails.logger.info cron.errors
      end
    else
      time = "*/5 * * * * Asia/Shanghai"
      cron.cron = time
      cron.save
      cron.enque! if need_enque!
    end
  end

  # cron任务名称
  def job_name
    "TSkJobInstancesJob-#{self.spider_name}"
  end


  def stop_task
    job = Sidekiq::Cron::Job.find job_name
    job.destroy if job.present?
  end

  def start_task
    job = Sidekiq::Cron::Job.find job_name
    if job.present?
    else

    end
    job.destroy if job.present?
  end
end
