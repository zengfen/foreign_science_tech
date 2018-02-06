# == Schema Information
#
# Table name: settings
#
#  id         :integer          not null, primary key
#  var        :string           not null
#  value      :text
#  thing_id   :integer
#  thing_type :string(30)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join("config/app.yml")
  namespace Rails.env
end


module EsConnect
	def EsConnect.new(es_hosts = Setting["es_hosts"].collect{|x| x.symbolize_keys!})
		  Elasticsearch::Client.new hosts:es_hosts ,randomize_hosts: true, log: false,send_get_body_as: "post"
	end
end