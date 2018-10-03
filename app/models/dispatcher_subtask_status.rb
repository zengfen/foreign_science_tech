# == Schema Information
#
# Table name: subtask_statuses
#
#  id            :string(32)       not null, primary key
#  task_id       :integer
#  status        :integer
#  created_at    :bigint(8)
#  error_content :text(65535)
#

class DispatcherSubtaskStatus < DispatcherBase
  self.table_name = 'subtask_statuses'

  has_one :dispatcher_subtask, foreign_key: :id
  belongs_to :dispatcher_subtask, foreign_key: :id

  def self.sync_status
    SpiderTask.where(spider_id: 128).each do |spider|
      next if spider.status != 2
      tasks = DispatcherSubtaskStatus.where(task_id: spider.id, status: 3)
      has_expire_cookie = false
      tasks.each do |x|
        subtask = DispatcherSubtask.find(x.id)
        content = JSON.parse(subtask.content)['url']
        if x.error_content == "cookie is expired"
          has_expire_cookie = true
          break
        end
        next unless x.error_content == "This profile can't be accessed"
        name = ArchonLinkedinName.where(id: content).first
        if name.blank?
          begin
            ArchonLinkedinName.create(id: content, is_dump: true, is_invalid: true)
          rescue Exception => _
            nil
          end
        else
          name.is_dump = true
          name.is_invalid = true
          name.save
        end
      end


      # if has_expire_cookie
      #   ControlTemplate.find(66).accounts.each do |x|
      #     x.valid_time = 1.hour.ago
      #     x.save
      #   end
      #   break
      # end
      spider.destroy
    end
  end

  def self.sync_status_new
    SpiderTask.where(spider_id: 128).each do |spider|
      next if spider.status != 2
      tasks = DispatcherSubtaskStatus.where(task_id: spider.id, status: 3)
      tasks.each do |x|
        subtask = DispatcherSubtask.find(x.id)
        content = JSON.parse(subtask.content)['url']
        if x.error_content == "cookie is expired"
          spider.retry_fail_task(x.id)
        end
        next unless x.error_content == "This profile can't be accessed"
        name = ArchonLinkedinName.where(id: content).first
        if name.blank?
          begin
            ArchonLinkedinName.create(id: content, is_dump: true, is_invalid: true)
          rescue Exception => _
            nil
          end
        else
          name.is_dump = true
          name.is_invalid = true
          name.save
        end
      end


      # if has_expire_cookie
      #   ControlTemplate.find(66).accounts.each do |x|
      #     x.valid_time = 1.hour.ago
      #     x.save
      #   end
      #   break
      # end
      # spider.destroy
    end
  end


  def self.retry_all
    SpiderTask.where(spider_id: 128).each do |spider|
      next if spider.status != 2
      tasks = DispatcherSubtaskStatus.where(task_id: spider.id, status: 3)
      tasks.each do |x|
        if x.error_content == "cookie is expired"
          spider.retry_fail_task(x.id)
        end
      end


      # if has_expire_cookie
      #   ControlTemplate.find(66).accounts.each do |x|
      #     x.valid_time = 1.hour.ago
      #     x.save
      #   end
      #   break
      # end
      # spider.destroy
    end
  end



  def self.check_accounts
    while true
      ids = SpiderTask.where(spider_id: 128, status: 1).collect(&:id)
      if task.blank?
        sleep(10)
        next
      end

      subtask = DispatcherSubtaskStatus.where(task_id: ids, status: 3, error_content: "cookie is expired").order("created_at desc").first
      if  !subtask.blank?
        ControlTemplate.find(66).accounts.each do |x|
          x.valid_time = 5.minute.ago
          x.save
          x.remove_related_data
        end

        SpiderTask.where(spider_id: 128, status: 1).each do |x|
          x.stop!
        end
      end

      sleep(10)
    end
  end
end
