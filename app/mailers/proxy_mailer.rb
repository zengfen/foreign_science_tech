class ProxyMailer < ApplicationMailer

	# ProxyMailer.inactive_monitor(["zengfen@china-revival.com.com"],["123"]).deliver_now
	def inactive_monitor(to_users,inactive_proxy)

		@inactive_proxy = inactive_proxy

		@title = "异常代理"
		mail to: to_users.join(';'), subject: "国际传播服务项目代理监控-#{ENV["ProjectName"]}"
	end
end