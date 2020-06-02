# == Schema Information
#
# Table name: spider_tasks
#
#  id                         :bigint           not null, primary key
#  spider_id                  :integer
#  level                      :integer          default(1)
#  full_keywords              :text(16777215)
#  keywords_summary           :string(255)
#  special_tag                :string(255)
#  status                     :integer          default(0)
#  max_retry_count            :integer          default(0), not null
#  current_retry_count        :integer          default(0), not null
#  spider_cycle_task_id       :integer
#  task_type                  :integer          default(1)
#  additional_function        :json
#  begin_time                 :datetime
#  end_time                   :datetime
#  current_task_count         :integer          default(0), not null
#  current_success_count      :integer          default(0), not null
#  current_fail_count         :integer          default(0), not null
#  current_warning_count      :integer          default(0), not null
#  current_result_count       :integer          default(0), not null
#  current_waiting_count      :integer          default(0), not null
#  maybe_completed_task_count :integer          default(0), not null
#  maybe_completed_at         :datetime
#  completed_at               :datetime
#  deleted_at                 :datetime
#  last_recover_at            :datetime
#  is_deleted_subtasks        :boolean          default(FALSE), not null
#  is_count_site              :boolean          default(FALSE), not null
#  split_group_count          :integer
#  timeout_second             :integer          default(15), not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  is_download_media          :boolean          default(FALSE), not null
#
# Indexes
#
#  s_status   (status)
#  spider_id  (spider_id)
#  st_scti    (spider_cycle_task_id)
#  st_tt      (task_type)
#

class SpiderTask < ApplicationRecord
  validates :spider_id, presence: true
  has_many :subtasks, dependent: :destroy, foreign_key: :task_id
  belongs_to :spider

  TypeTaskWait = 0 # 未启动
  TypeTaskStart = 1 # 启动
  TypeTaskComplete = 2 # 完成
  TypeTaskStop = 3 # 暂停
  TypeTaskReopen = 4 # 重启
  StatusList = {TypeTaskWait => '未启动',
                TypeTaskStart => '已启动',
                TypeTaskComplete => '已完成',
                TypeTaskStop => '已暂停', }.freeze


  RealTimeTask = 0
  CycleTask = 1
  TypesList = {RealTimeTask => '实时单次任务',
               CycleTask => '周期单次任务'
  }


  def self.during(start_date, end_date)
    self.where(created_at: (start_date..end_date.end_of_day))
  end


  def self.t_log_spider_mode
    {0 => 'real-time',
     1 => 'cycle'
    }
  end

  def status_cn
    StatusList[status]
  end

  def task_type_cn
    TypesList[task_type]
  end

  def can_start?
    status == TypeTaskStop || status == TypeTaskWait
  end

  # 周期任务生成的单次任务不能停止
  def can_stop?
    status == TypeTaskStart
    # && task_type == SpiderTask::RealTimeTask
  end


  def can_reopen?
    status == TypeTaskStop
  end

  def create_subtasks
    line = JSON.parse(Base64.decode64(self.full_keywords)) rescue {}
    task = {"status" => SpiderTask::TypeTaskStart}
    task["content"] = line.to_json
    task["id"] = Subtask.make_id(line.merge!("task_id"=>self.id))
    task["task_id"] = self.id
    # 创建子任务
    subtask = Subtask.create(task) rescue nil
    # return if subtask.blank?
    key = Subtask.task_key(self.id)
    $redis.sadd(key, task["id"])
  end


  def process_status
    case self.status
      when TypeTaskStart
        self.process_start
      when TypeTaskStop
        self.process_stop
      when TypeTaskReopen
        self.process_reopen
    end
  end

  def process_start
    key = Subtask.task_key(self.id)
    success_key = Subtask.task_success_key(self.id)
    error_key = Subtask.task_error_key(self.id)
    while true
      subtask_ids = []
      200.times do
        subtask_id = $redis.spop(key)
        subtask_ids << subtask_id if subtask_id.present?
      end
      if subtask_ids.blank?
        flag = self.process_deleted
        return if flag
      end
      subtask_ids.each do |subtask_id|
        subtask = Subtask.find(subtask_id) rescue nil
        next if subtask.blank?
        line = JSON.parse(subtask.content) rescue {}
        error_content = process_one_task(line)
        # 将任务结果缓存到redis中
        if error_content.to_h[:type] == "error"
          $redis.sadd(error_key, {id: subtask_id, error_content: error_content.to_h[:message], error_at: Time.now.to_i, status: Subtask::TypeSubtaskError}.to_json)
        else
          $redis.sadd(success_key, {id: subtask_id, error_content: error_content.to_h[:message], competed_at: Time.now.to_i, status: Subtask::TypeSubtaskSuccess}.to_json)
        end
      end
    end
  end

  def process_one_task(line)
    key = Subtask.task_key(self.id)
    # begin
    model_tasks = eval(line["spider_name"]).new.send(line["mode"], line["body"])
    return model_tasks if line["mode"] == "item"
    subtasks = []
    model_tasks.each do |new_line|
      new_line = new_line.stringify_keys
      new_line["spider_name"] = line["spider_name"]
      task = {"status" => SpiderTask::TypeTaskStart}
      task["id"] = Subtask.make_id(new_line.merge("task_id"=>self.id))
      task["task_id"] = self.id
      task["content"] = new_line.to_json
      subtasks << task
    end
    subtasks = subtasks.uniq
    # ActiveRecord::Base.transaction do
    destination_columns = subtasks.first.keys
    Subtask.bulk_insert(*destination_columns, ignore: true, set_size: 5000) do |worker|
      subtasks.each do |data|
        worker.add(data)
      end
    end
    # 更新count
    self.update(current_task_count: self.current_task_count + subtasks.count)
    $redis.sadd(key, subtasks.map { |x| x["id"] })
    # end
    return nil
    # rescue Exception => e
    #   return e
    # end
  end

  # 删除和更新跑完的任务
  def process_deleted
    key = Subtask.task_key(self.id)
    success_key = Subtask.task_success_key(self.id)
    error_key = Subtask.task_error_key(self.id)
    while true
      results_success = []
      200.times do
        result = $redis.spop(success_key)
        results_success << JSON.parse(result) if result.present?
      end
      if results_success.present?
        Subtask.where(id: results_success.map { |x| x["id"] }).delete_all
        current_success_count = self.current_success_count + results_success.count
        self.update(current_success_count: current_success_count)
      end

      results_error = []
      200.times do
        result = $redis.spop(error_key)
        results_error << JSON.parse(result) if result.present?
      end
      if results_error.present?
        destination_columns = results_error.first.keys
        puts "destination_columns=======+#{destination_columns}  results_error=======+#{results_error}"
        Subtask.bulk_insert(*destination_columns, ignore: true, update_duplicates: true) do |worker|
          results_error.each do |data|
            worker.add(data)
          end
        end

        current_fail_count = self.current_fail_count + results_error.count
        self.update(current_fail_count: current_fail_count)
      end

      return true if status == TypeTaskStop

      if results_success.blank? && results_error.blank? && status == TypeTaskStart
        #  && Subtask.where(task_id: self.id, status: Subtask::TypeSubtaskStart).none?
        self.update(status: SpiderTask::TypeTaskComplete)
        $redis.del(key, success_key, error_key)
        return true
      else
        return false
      end

    end
  end

  def process_stop
    key = Subtask.task_key(self.id)
    tasks = $redis.smembers(key)
    $redis.del(key)
    pause_key = Subtask.task_pause_key(self.id)
    $redis.sadd(pause_key, tasks) if tasks.present?
  end

  def process_reopen
    pause_key = Subtask.task_pause_key(self.id)
    tasks = $redis.smembers(pause_key)
    $redis.del(pause_key)
    key = Subtask.task_key(self.id)
    $redis.sadd(key, tasks) if tasks.present?
    self.update(status: TypeTaskStart)
    # self.process_start
  end


  # mode 启动模式  0：周期启动，1：实时启动
  def start_task
    return {type: "error", message: "任务不能启动"} unless can_start?
    spider_name = self.spider.spider_name
    job_instance = TSkJobInstance.where(spider_name: spider_name).first
    if job_instance.blank?
      return {type: "error", message: "对应TSkJobInstance实例为空"}
    end
    # # 周期任务直接可以执行，实时任务需判断状态后执行
    # if self.task_type == SpiderTask::RealTimeTask
    #   return {type: "error",message: "任务正在执行中"} unless can_start?
    # end
    log_mode = SpiderTask.t_log_spider_mode[self.task_type]
    # 创建一条爬虫日志数据
    TLogSpider.create({spider_name: spider_name, start_time: Time.now, mode: log_mode})
    # 创建子任务 缓存子任务
    self.create_subtasks
    self.update(status: SpiderTask::TypeTaskStart,current_task_count:self.current_task_count + 1)
    # 检查任务状态，处理任务
    # spider_task.process_status
    return {type: "success", message: "任务启动成功"}

  end

  def stop_task
    return {type: "error", message: "任务不能停止"} unless can_stop?
    self.update(status: SpiderTask::TypeTaskStop)
    # # 检查任务状态，处理任务
    self.process_status
    return {type: "success", message: "任务暂停成功"}
  end

end
