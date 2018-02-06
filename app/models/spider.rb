# == Schema Information
#
# Table name: spiders
#
#  id                  :integer          not null, primary key
#  spider_name         :string
#  spider_type         :integer
#  network_environment :integer          default(1)
#  proxy_support       :boolean          default(FALSE)
#  has_keyword         :boolean          default(TRUE)
#  template_name       :string
#  category            :string
#  additional_function :json             is an Array
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  control_template_id :integer
#  instruction         :string
#  has_time_limit      :boolean          default(FALSE)
#

class Spider < ApplicationRecord
  has_many :spider_cycle_tasks, dependent: :destroy
  has_many :spider_tasks, dependent: :destroy
  belongs_to :control_template

  validates :spider_name, presence: true, length: { maximum: 50 },
    uniqueness: { case_sensitive: false }

  def self.index_categories
    {
      '新闻' => 'archon_news',
      '论坛' => 'archon_bbs',
      '微博' => 'archon_weibo',
      '视频' => 'archon_video',
      '电商' => 'archon_electric_business',
      '图片' => 'archon_picture',
      '问答' => 'archon_question',
      '社交' => 'archon_sns_post',
      '博客' => 'archon_blog',
      '招聘' => 'archon_hiring',
      '新闻评论' => 'archon_news_comment',
      '酒店评论' => 'archon_hotel_comments',
      "Facebook" => "archon_facebook_post",
      "Twitter" => "archon_twitter_post"
    }
  end

  def self.categories
    {
      '新闻' => 'news',
      '论坛' => 'forums',
      '微博' => 'weibo',
      '视频' => 'video',
      '电商' => 'electric_business',
      '图片' => 'picture',
      '问答' => 'question',
      '社交' => 'sns_post',
      '博客' => 'blog',
      '招聘' => 'hiring',
      '新闻评论' => 'news_comment',
      '酒店评论' => 'hotel_comments',
      'Facebook' => "facebook_post",
      'Twitter' => "twitter_post",
    }
  end

  def category_cn
    Spider.categories.invert[category]
  end

  def self.spider_types
    {
      'html解析' => 1,
      'api' => 2,
      '自定义脚本' => 3
    }
  end

  def spider_type_cn
    Spider.spider_types.invert[spider_type]
  end

  def self.network_environments
    { '境内' => 1, '境外' => 2 }
  end

  def network_environment_cn
    Spider.network_environments.invert[network_environment]
  end

  def self.build_spider(spider_params)
    additional_function = spider_params.delete(:additional_function)
    spider = Spider.new(spider_params)
    unless additional_function.blank?
      begin
        spider.additional_function = JSON.parse(additional_function)
      rescue StandardError
        spider.errors.add(:additional_function, '格式错误')
      end
    end
    spider
  end

  def self.create_index(category, dates)
    dates.each do |date|
      category.classify.constantize.create_index(date)
    end
  end
end
