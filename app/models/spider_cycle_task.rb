# == Schema Information
#
# Table name: spider_cycle_tasks
#
#  id              :integer          not null, primary key
#  spider_id       :integer
#  level           :integer          default("1")
#  keyword         :string
#  special_tag     :string
#  status          :integer          default("0")
#  success_count   :integer          default("0")
#  fail_count      :integer          default("0")
#  max_retry_count :integer          default("2")
#  warning_count   :integer          default("0")
#  period          :string
#  next_time       :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
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
    cn_hash = { 0 => '等待执行', 1 => '执行中', 2 => "已暂停"}
    cn_hash[status]
  end

  def init_task_job
  	self.task_job_run!
  end

  def job_name
    "CycleTaskJob-#{self.id}"
  end

  def self.period_list
  	{
  		"month"=>{:cron=>"* * * */1 *",:time=>1.month},
      "week"=>{:cron=>"* * * * */1",:time=>1.week},
      "day"=>{:cron=>"* * */1 * *",:time=> 1.day},
      "hour"=>{:cron=>"* */1 * * *",:time=> 1.hour},
      "30min"=>{:cron=>"*/30 * * * *",:time=>30.minutes},
      "10min"=>{:cron=>"*/10 * * * *",:time=> 10.minutes},
    }
  end

  def period_opts
  	SpiderCycleTask.period_list[self.period]
  end

  def task_job_run!
  	cron = Sidekiq::Cron::Job.find self.job_name
  	Sidekiq::Cron::Job.create(name: self.job_name, cron: self.period_opts[:cron], class: 'CycleTaskJob', args:  { id: self.id }) if cron.blank?
  end

  def destroy_job!
  	cron = Sidekiq::Cron::Job.find self.job_name
  	Sidekiq::Cron::Job.destroy self.job_name if !cron.blank?
  	self.update_attributes({:status=>2})
  end

  def create_sub_task
  	self.update_attributes({:status=>1})
  	st_params  = JSON.parse(self.dup.to_json).deep_symbolize_keys.merge!({:spider_cycle_task_id=>self.id,:task_type=>2})
  	st_params.delete(:period)
  	st_params.delete(:next_time)
  	st_params.delete(:status)
  	st = SpiderTask.new(st_params)
  	st.save
  	st
  end

  def update_next_time
  	self.update_attributes(:next_time=>Time.now+(self.period_opts[:time]),:status=>0)
  end

  def save_with_spilt_keywords
    if spider.has_keyword && !spider.blank?
      keywords = keyword.split(',')
      keywords.each do |keyword|
        spider_cycle_task = self.dup
        spider_cycle_task.keyword = keyword
        return { 'error' => spider_cycle_task.errors.full_messages.join('\n') } unless spider_cycle_task.save
      end
    else
      return { 'error' => spider_cycle_task.errors.full_messages.join('\n') } unless save
    end
    { 'success' => '保存成功！' }
  end
end
