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


  def window_type_cn
    self.class.window_types[self.window_type]
  end

  def self.window_durations
    {
      0 => 1.minute,
      1 => 1.hour,
      2 => 1.day
    }
  end

  def window_to_duration
    window_size * self.class.window_durations[window_type].to_i * 1000
  end

  def save_with_calculate!
    self.window_type ||= 1
    self.window_size ||= 1

    self.max_count ||= -1

    if self.max_count == -1
      self.interval_in_ms = 1
    else
      self.interval_in_ms = self.window_to_duration
    end

    return {'success' => '保存成功！'} if self.save

    {'error' => self.errors.full_messages.join('\n')}
  end
end
