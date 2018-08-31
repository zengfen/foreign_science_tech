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
#  dep_templates            :json             not null
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

  attr_accessor :template_name1, :template_name2, :template_name3, :template_name4, :template_name5
  attr_accessor :control_template_id1, :control_template_id2, :control_template_id3, :control_template_id4, :control_template_id5

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
      '字幕' => 'timed_text',
      "商户" => "place",
      "景点评论" => "scenic_comment",
      "Okidb人物" => "temp_person_record"
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

    temp_templates = {}
    (1..5).to_a.each do |i|
      template_name = spider.send("template_name#{i}")
      next if template_name.blank?
      template_name.strip!

      if temp_templates.include?(template_name)
        spider.errors.add("template_name#{i}".to_sym, '模板重复')
        return spider
      end

      control_id = spider.send("control_template_id#{i}")
      temp_templates[template_name] = control_id unless template_name.blank?
    end
    spider.dep_templates = temp_templates


    is_internal = spider.network_environment == 1

    if !spider.control_template.blank? && spider.control_template.is_internal != is_internal
      spider.errors.add('network_environment', '控制模板网络环境不一致')
      return spider
    end

    spider
  end

  # def self.create_index(category, dates)
  #   dates.each do |date|
  #     category.classify.constantize.create_index(date)
  #   end
  # end

  def accounts_is_valid?
    ids = []
    unless control_template_id.blank?
      ids << control_template.id

    end

    dep_templates.each do |_k, v|
      c = ControlTemplate.find(v)
      ids << c.id
    end

    ids.each do |x|
      c = ControlTemplate.find(x)
      if !c.accounts_is_valid?
        return false
      end
    end

    return true
  end

  def control_template_id_details
    ids = []
    unless control_template_id.blank?
      ids << control_template.id
      ids << if control_template.is_bind_ip
               '1'
             else
               '0'
             end
    end

    dep_templates.each do |_k, v|
      c = ControlTemplate.find(v)
      ids << c.id
      ids << if c.is_bind_ip
               '1'
             else
               '0'
             end
    end

    ids.join(',')
  end

  def add_control_template_id
    $archon_redis.hset('archon_template_control_id', template_name, control_template_id || '')

    dep_templates.each do |k, v|
      $archon_redis.hset('archon_template_control_id', k, v || '')
    end
  end

  def remove_control_template_id
    $archon_redis.hdel('archon_template_control_id', template_name)
    dep_templates.each do |k, _v|
      $archon_redis.hdel('archon_template_control_id', k)
    end
  end


  def update_dep_templates(templates)
    return if templates.blank?

    d = {}

    templates.each do |x|
      d[x] = self.control_template_id
    end

    self.dep_templates = d
    self.save
  end


  def set_control_template
    i = 1
    self.dep_templates.each do |k, v|
      break if i > 5
      self.send("template_name#{i}=", k)
      self.send("control_template_id#{i}=", v)
      i += 1
    end
  end
end
