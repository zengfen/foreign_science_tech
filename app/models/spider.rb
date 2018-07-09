# == Schema Information
#
# Table name: spiders
#
#  id                       :bigint(8)        not null, primary key
#  spider_name              :string
#  spider_type              :integer
#  network_environment      :integer          default(1)
#  proxy_support            :boolean          default(FALSE)
#  has_keyword              :boolean          default(TRUE)
#  template_name            :string
#  category                 :string
#  additional_function      :json             is an Array
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  control_template_id      :integer
#  instruction              :string
#  has_time_limit           :boolean          default(FALSE)
#  dep_control_template_ids :integer          default([]), not null, is an Array
#

class Spider < ApplicationRecord
  has_many :spider_cycle_tasks, dependent: :destroy
  has_many :spider_tasks, dependent: :destroy
  belongs_to :control_template

  validates :spider_name, presence: true, length: { maximum: 50 },
                          uniqueness: { case_sensitive: false }

  after_create :add_control_template_id
  before_destroy :remove_control_template_id

  validates_uniqueness_of :template_name

  def self.categories
    {
      '新闻' => 'news',
      '论坛' => 'forums',
      '微博' => 'weibo',
      '视频' => 'video',
      '视频评论' => 'video_comment',
      '电商' => 'electric_business',
      '图片' => 'picture',
      '图片评论' => 'picture_comment',
      '问答' => 'question',
      '社交' => 'sns_post',
      '博客' => 'blog',
      '招聘' => 'hiring',
      '新闻评论' => 'news_comment',
      '酒店评论' => 'hotel_comment',
      'Facebook' => 'facebook_post',
      'Facebook评论' => 'facebook_comment',
      'Twitter' => 'twitter',
      'Linkedin' => 'linkedin',
      '字幕' => 'timed_text'
    }
  end

  def tidb_table_name
    "archon_#{category}"
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

  def add_control_template_id
    $archon_redis.hset("archon_spider_ids", self.template_name, self.id)
    $archon_redis.hset("archon_spiders", self.id, self.template_name)
    $archon_redis.hset('archon_template_control_id', template_name, control_template_id || '')
    dep_ids = self.dep_control_template_ids
    dep_ids << self.control_template_id
    dep_ids.uniq!
    dep_ids.delete(nil)
    dep_ids.delete("")

    $archon_redis.hset("archon_spider_control_ids", template_name, dep_ids.join(","))
  end

  def remove_control_template_id
    $archon_redis.hdel("archon_spider_ids", self.template_name)
    $archon_redis.hdel("archon_spiders", self.id)
    $archon_redis.hdel('archon_template_control_id', template_name)
    $archon_redis.hdel('archon_spider_control_ids', template_name)
  end
end
