class WorkListMailer < ApplicationMailer
	def send_mail(email,message)

		@message = message
		mail to: email, subject: "工单提醒"
	end
end