class UserMailer < ActionMailer::Base
  include Resque::Mailer

  default from: Hmcustomers.config.system_email

  def forgot_login_email(user_id)
    @user = WebUser.find(user_id)

    mail to: @user.email_address,
    subject: "Your #{Hmcustomers.config.company_name} log in information"
  end

  def new_password_email(user_id, new_password)
    @user = WebUser.find(user_id)
    @new_password = new_password

    mail to: @user.email_address,
    subject: "Your new #{Hmcustomers.config.company_name} password"
  end
end
