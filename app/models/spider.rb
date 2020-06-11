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

  after_destroy :destroy_cron

  def self.status_list
    cn_hash = {0 => '未启动', 1 => '周期运行中', 2 => '已停止'}
    return cn_hash
  end

  def status_cn
    Spider.status_list[status]
  end

  def real_time_status_cn
    self.spider_tasks.order(:created_at).last.status_cn rescue '未启动'
  end

  def self.init_next_time
    Spider.all.each do |x|
      job_instance = TSkJobInstance.where(spider_name:x.spider_name).first
      day = Date.today.strftime("%F")
      time = job_instance.cron_hour.to_i.to_s + ":" + job_instance.cron_minutes.to_i.to_s
      time = Time.parse("#{day} #{time}")
      next_time = Time.now > time ? time + 1.day : time
      x.update(status:1,next_time:next_time)
    end
  end


  #===========================================================


  def create_spider_task(mode)
    line = {"mode" => "list", "spider_name" => self.spider_name, "body" => {}}
    keyword = Base64.encode64(line.to_json).gsub("\n", "")
    spider_task = SpiderTask.new(spider_id: self.id, full_keywords: keyword, status: SpiderTask::TypeTaskWait,task_type: mode,current_task_count: 0)
    if spider_task.save
      return {type:"success",message:"创建成功"},spider_task
    else
      return {type:"error",message:spider_task.errors.full_messages.join('\n')},spider_task
    end
  end


  def destroy_cron
    instance = TSkJobInstance.where(spider_name:self.spider_name).first
    return if instance.blank?
    cron = Sidekiq::Cron::Job.find instance.job_name
    cron.destroy if cron.present?
    # instance.destroy
  end

end
