class CommonMailer < ActionMailer::Base
  include Resque::Mailer

  default from: Hmcustomers.config.system_email

  def contact_us_email(user_id, message)
    @user    = WebUser.find(user_id)
    @message = message

    mail to: Hmcustomers.config.contact_email,
    subject: "New message from GrainWeb user"
  end
end
