class ApplicationMailer < ActionMailer::Base
  default charset: "utf-8"
  default content_type: "text/html"
  layout 'mailer'
end
