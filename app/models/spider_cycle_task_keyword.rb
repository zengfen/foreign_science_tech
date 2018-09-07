# == Schema Information
#
# Table name: spider_cycle_task_keywords
#
#  id             :bigint(8)        not null, primary key
#  spider_task_id :integer
#  keyword        :text
#

class SpiderCycleTaskKeyword < ApplicationRecord
  belongs_to :spider_cycle_task
end
