class LadingMailer < ActionMailer::Base
  include Resque::Mailer

  default from: Hmcustomers.config.system_email

  def requests_email(amount, address)
    @amount  = amount
    @address = address

    mail to: Hmcustomers.config.lading_requests_email,
    subject: "Lading requests"
  end
end
