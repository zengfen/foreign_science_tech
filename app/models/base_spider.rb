class BaseSpider < ApplicationRecord
  belongs_to :control_template

  validates :name, presence: true, length: { maximum: 50 },
                   uniqueness: { case_sensitive: false }

  validates :template_name, presence: true, length: { maximum: 50 },
                            uniqueness: { case_sensitive: false }

  # after_create :sync_to_redis

  def control_template_name
    return '' if control_template_id.blank?

    control_template.name
  end

  def sync_to_redis
    $archon_redis.hset('archon_template_control_id', template_name, control_template_id || '')
  end

  # def self.build_spider(spider_params)
  #   spider = BaseSpider.new(spider_params)

  #   temp_templates = {}
  #   (1..5).to_a.each do |i|
  #     template_name = spider.send("template_name#{i}")
  #     next if template_name.blank?
  #     template_name.strip!

  #     if temp_templates.include?(template_name)
  #       spider.errors.add("template_name#{i}".to_sym, '模板重复')
  #       return spider
  #     end

  #     control_id = spider.send("control_template_id#{i}")
  #     temp_templates[template_name] = control_id unless template_name.blank?
  #   end
  #   spider.dep_templates = temp_templates

  #   spider
  # end
end
