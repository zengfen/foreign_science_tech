class BaseSpider < ApplicationRecord
  belongs_to :control_template

  def control_template_name
    return '' if control_template_id.blank?

    control_template.name
  end
end
