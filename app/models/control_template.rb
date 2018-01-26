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
#

class ControlTemplate < ApplicationRecord
end
