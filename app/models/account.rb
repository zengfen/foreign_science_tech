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

  validates :content, presence: true, uniqueness: { case_sensitive: false }

  belongs_to :control_template

  def self.account_types
    {
      0 => '账号',
      1 => 'Token',
      2 => 'Cookies'
    }
  end

  def account_type_cn
    self.class.account_types[account_type]
  end

  def is_valid?
    Time.now < valid_time ? '有效' : '无效'
  end

  def save_with_split!
    return { 'error' => '内容为空' } if contents.blank?

    contents.split("\n").each do |line|
      next if line.blank?

      account = Account.new(content: line.strip,
                            account_type: account_type,
                            valid_time: valid_time,
                            control_template_id: control_template_id)
      account.save
    end

    { 'success' => '保存成功！' }
  end
end
