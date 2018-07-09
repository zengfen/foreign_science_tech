# == Schema Information
#
# Table name: spider_cycle_tasks
#
#  id                  :bigint(8)        not null, primary key
#  spider_id           :integer
#  level               :integer          default(1)
#  keyword             :text
#  special_tag         :string
#  status              :integer          default(0)
#  success_count       :integer          default(0)
#  fail_count          :integer          default(0)
#  max_retry_count     :integer          default(2)
#  warning_count       :integer          default(0)
#  period              :string
#  next_time           :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  additional_function :json
#  begin_time          :datetime
#  end_time            :datetime
#  is_split            :boolean          default(FALSE)
#  is_time_delta       :boolean          default(FALSE), not null
#

class SpiderCycleTask < ApplicationRecord
  validates :spider_id, presence: true
  validates :level, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :max_retry_count, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :period, presence: true

  has_many :spider_tasks
  belongs_to :spider

  after_create :init_task_job

  before_destroy :destroy_job!

  def status_cn
    cn_hash = { 0 => "未启动",1 =>"周期运行中", 2 => "已停止"}
    cn_hash[status]
  end

  def init_task_job
    self.task_job_run!
  end

  def can_stop?
    self.status == 1
  end

  def can_start?
    self.status == 0 || self.status == 2
  end

  def job_name
    "CycleTaskJob-#{self.id}"
  end

  def self.period_list
    {
      "1month"=>{:cron=>"0 0 1 * * Asia/Shanghai",:time=>1.month},
      "1week"=>{:cron=>"0 0 * * 1 Asia/Shanghai",:time=>1.week},
      "2day"=>{:cron=>"0 0 */2 * * Asia/Shanghai",:time=> 2.day},
      "1day"=>{:cron=>"0 0 * * * Asia/Shanghai",:time=> 1.day},
      "12hour"=>{:cron=>"0 */12 * * * Asia/Shanghai",:time=> 12.hour},
      "6hour"=>{:cron=>"0 */6 * * * Asia/Shanghai",:time=> 6.hour},
      "3hour"=>{:cron=>"0 */3 * * * Asia/Shanghai",:time=> 3.hour},
      "2hour"=>{:cron=>"0 */2 * * * Asia/Shanghai",:time=> 2.hour},
      "1hour"=>{:cron=>"0 * * * * Asia/Shanghai",:time=> 1.hour},
      "30mins"=>{:cron=>"*/30 * * * * Asia/Shanghai",:time=>30.minutes},
      "10mins"=>{:cron=>"*/10 * * * * Asia/Shanghai",:time=> 10.minutes},

    }
  end

  def period_opts
    SpiderCycleTask.period_list[self.period]
  end

  def task_job_run!
    return if !self.can_start?

    cron = Sidekiq::Cron::Job.find self.job_name
    Sidekiq::Cron::Job.create(name: self.job_name, cron: self.period_opts[:cron], class: 'CycleTaskJob', args:  { id: self.id }) if cron.blank?

    self.update_attributes({:status=>1})
    self.update_next_time
  end

  def destroy_job!
    cron = Sidekiq::Cron::Job.find self.job_name
    Sidekiq::Cron::Job.destroy self.job_name if !cron.blank?
  end

  def stop_job!
    return if !self.can_stop?

    job = Sidekiq::Cron::Job.find self.job_name
    Sidekiq::Cron::Job.destroy self.job_name if !job.blank?
    self.update_attributes({:status=>2})
    self.update_attributes(:next_time=>nil)
  end

  def create_sub_task
    st_params  = JSON.parse(self.dup.to_json).deep_symbolize_keys.merge!({:spider_cycle_task_id=>self.id,:task_type=>2})
    st_params.delete(:period)
    st_params.delete(:next_time)
    st_params.delete(:status)
    st_params.delete(:is_time_delta)

    if self.is_time_delta
      st_params[:begin_time] = self.begin_time
      # st_params[:end_time] = self.next_time
    end
    st = SpiderTask.new(st_params)
    st.save
    st.enqueue
    #创建完成后自动运行
    st.start!
    st
  end

  def special_tag_names
    tag_names = []
    self.special_tag.split(",").each do |x|
      st = SpecialTag.find(x) rescue nil
      tag_names << st.tag if st
    end
    tag_names
  end

  def update_next_time
    cron = Rufus::Scheduler::CronLine.new(Sidekiq::Cron::Job.find(self.job_name).cron)
    next_time = cron.next_time(Time.now.utc).utc
    self.update_attributes(:next_time=>next_time, :begin_time => Time.now)
  end

  def special_tag_transfor_id
    specital_tags_ids = self.special_tag.split(",").collect{|tag| SpecialTag.create_with({:tag=>tag,:created_at=>Time.now,:updated_at=>Time.now}).find_or_create_by(:tag=>tag).id }.join(",")
    self.special_tag = specital_tags_ids
  end

  def save_with_spilt_keywords
    if spider.has_keyword && !spider.blank?
      keywords = keyword.split(',').collect(&:strip).uniq
      keywords.delete(nil)
      keywords.delete('')
      if is_split
        keywords.each do |keyword|
          spider_cycle_task = dup
          spider_cycle_task.keyword = keyword
          return { 'error' => spider_cycle_task.errors.full_messages.join('\n') } unless spider_cycle_task.save
        end
      else
        self.keyword = keywords.join(',')
        return { 'error' => errors.full_messages.join('\n') } unless save
      end
    else
      return { 'error' => spider_cycle_task.errors.full_messages.join('\n') } unless save
    end
    { 'success' => '保存成功！' }
  end
end
