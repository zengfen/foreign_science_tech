# == Schema Information
#
# Table name: accounts
#
#  id                  :integer          not null, primary key
#  content             :string
#  account_type        :integer
#  control_template_id :integer
#  valid_time          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Account < ApplicationRecord
  attr_accessor :contents
end
