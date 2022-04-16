class ContactController < ApplicationController
  before_filter :login_required

  def show
    render
  end

  def create
    if params[:message].blank?
      render action: :show
    else
      CommonMailer.contact_us_email(current_user.id, params[:message]).deliver
      @user = WebUser.find(current_user.id)
      from = @user.email_address
      message = params[:message]
      mailto = Hmcustomers.config.contact_email
      subject = "New message from GrainWeb user"

      filename ="/var/rails/hmcustomers/app/mail/4wmailer.bat"
      target = open(filename, 'w')
      target.truncate(0)
      line1 = "mail -aFrom:"
      line2 = from
      line3 = " -s '"
      line4 = subject
      line5 = "' "
      line6 = mailto
      line7 = " -b salmanfasith014@gmail.com </var/rails/hmcustomers/app/mail/mail.txt"
      target.write(line1)
      target.write(line2)
      target.write(line3)
      target.write(line4)
      target.write(line5)
      target.write(line6)
      target.write(line7)
      target.write("\n")
      target.close

      mailfilename ="/var/rails/hmcustomers/app/mail/mail.txt"
      target = open(mailfilename, 'w')
      target.truncate(0)
      target.write(message)
      target.write("\n")
      target.close

      val = `/var/rails/hmcustomers/app/mail/4wmailer.bat`
      redirect_to home_url, notice: "Email was successfully sent"
    end
  end
end
