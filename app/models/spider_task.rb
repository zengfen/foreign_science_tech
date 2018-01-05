# == Schema Information
#
# Table name: spider_tasks
#
#  id            :integer          not null, primary key
#  spider_id     :integer
#  level         :integer          default("1")
#  keyword       :string
#  special_tag   :string
#  status        :integer          default("0")    {0=>"未执行",1=>"执行中",2=>"执行结束"}
#  success_count :integer          default("0")
#  fail_count    :integer          default("0")
#  refresh_time  :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class SpiderTask < ApplicationRecord
	validates :spider_id, presence: true
	validates :level, numericality: { only_integer: true,greater_than_or_equal_to:1,less_than_or_equal_to:10 }

	belongs_to :spider

	def status_cn
		cn_hash = {0=>"未执行",1=>"执行中",2=>"执行结束"}
		return cn_hash[self.status]
	end

	def save_with_spilt_keywords
		if self.spider.has_keyword&&!self.spider.blank?
			keywords = self.keyword.split(',')
			keywords.each do |keyword|
				spider_task  = self.dup
				spider_task.keyword = keyword
				return {"error"=>spider_task.errors.full_messages.join('\n')} if !spider_task.save
			end
		else
			return {"error"=>spider_task.errors.full_messages.join('\n')} if !self.save
		end
		return {"success"=>"保存成功！"}
	end
end
