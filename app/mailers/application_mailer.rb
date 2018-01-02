class ApplicationMailer < ActionMailer::Base
  default from: Setting.mailer_sender
  default charset: "utf-8"
  default content_type: "text/html"
  layout 'mailer'
end
