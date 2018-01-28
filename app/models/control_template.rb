# == Schema Information
#
# Table name: control_templates
#
#  id               :integer          not null, primary key
#  name             :string
#  is_bind_ip       :boolean
#  window_type      :integer
#  window_size      :integer
#  max_count        :integer
#  is_absolute_time :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  interval_in_ms   :integer
#

class ControlTemplate < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.window_types
    {
      0 => '分钟',
      1 => '小时',
      2 => '天'
    }
  end

  def save_with_calculate!
    self.window_type ||= 1
    self.window_size ||= 1

    self.max_count ||= -1

    self.interval_in_seconds = 1 if self.max_count == -1
  end
end
