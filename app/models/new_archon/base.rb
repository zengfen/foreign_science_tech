class Base < ActiveRecord::Base
  self.abstract_class = true
  establish_connection NewArchonCenter
end
