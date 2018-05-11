# == Schema Information
#
# Table name: special_tags
#
#  id         :integer          not null, primary key
#  tag        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SpecialTag < ApplicationRecord

  def self.tags
    all.collect{|x| [x.tag, x.id]}
  end
end
