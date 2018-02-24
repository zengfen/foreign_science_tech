class EsConnect
	def self.client(es_hosts = Setting["es_hosts"].collect{|x| x.symbolize_keys!})
		  Elasticsearch::Client.new hosts:es_hosts ,randomize_hosts: true, log: false,send_get_body_as: "post"
	end
end