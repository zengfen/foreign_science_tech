# == Schema Information
#
# Table name: accounts
#
#  id         :integer          not null, primary key
#  content    :text(65535)
#  valid_time :bigint(8)
#

class DispatcherAccount < DispatcherBase
  self.table_name = 'accounts'
end
