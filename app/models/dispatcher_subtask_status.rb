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
      tasks = DispatcherSubtaskStatus.where(task_id: id)
      tasks.each do |x|
        subtask = DispatcherSubtask.find(x.id)
        content = JSON.parse(subtask.content)['url']
        if x.status == 3
          if x.error_content == "This profile can't be accessed"
            name = ArchonLinkedinName.where(id: content).first
            if name.blank?
              ArchonLinkedinName.create(id: content, is_dump: true, is_invalid: true) rescue nil
            else
              name.is_dump = true
              name.is_invalid = true
              name.save
            end
          end
        end
      end
    end
  end
end
