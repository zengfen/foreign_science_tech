# == Schema Information
#
# Table name: spider_task_keywords
#
#  id             :bigint(8)        not null, primary key
#  spider_task_id :integer
#  keyword        :text
#

class SpiderTaskKeyword < ApplicationRecord
  belongs_to :spider_task
end
