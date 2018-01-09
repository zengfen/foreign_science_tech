# == Schema Information
#
# Table name: spiders
#
#  id                  :integer          not null, primary key
#  spider_name         :string
#  spider_type         :integer
#  network_environment :integer          default("1")
#  proxy_support       :boolean          default("false")
#  has_keyword         :boolean          default("false")
#  template_name       :string
#  category            :string
#  additional_function :json             is an Array
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Spider < ApplicationRecord
	has_many :spider_tasks, dependent: :destroy

  validates :spider_name, presence: true, length: { maximum: 50 },
                    uniqueness: { case_sensitive: false }

	def self.categories
		{
		 "新闻"=> "news",
		 "论坛"=> "forums",
		 "视频"=>"video",
		 "电商"=>"electric_business",
		 "图片"=>"picture",
		 "问答"=>"question",
		 "社交"=>"sns_post",
		 "博客"=>"blog",
		 "招聘"=>"hiring",
		 "新闻评论"=>"news_comment",
		 "酒店评论"=>"hotel_comments"
		}
	end

	def category_cn
		Spider.categories.invert[self.category]
	end

	def self.spider_types
		{
			"html解析"=>1,
			"api"=>2,
			"自定义脚本"=>3
		}
	end

	def spider_type_cn
		Spider.spider_types.invert[self.spider_type]
	end

	def self.network_environments
		{"境内"=>1, "境外"=>2}
	end

	def network_environment_cn
		Spider.network_environments.invert[self.network_environment]
	end

	def self.build_spider(spider_params)
		additional_function = spider_params.delete(:additional_function)
		spider = Spider.new(spider_params)
		if !additional_function.blank?
			begin
				spider.additional_function = JSON.parse(additional_function)
			rescue
				spider.errors.add(:additional_function, "格式错误")
			end
		end
		return spider
	end
end
