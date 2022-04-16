class LoginsController < ApplicationController
  def new
    render
  end

  def create
    email = params[:email]
    if !email.blank? && (user = WebUser.find_by_email_address(email))
      @user = WebUser.find(user.id)
      mailto = @user.email_address
      subject =  "'Your #{Hmcustomers.config.company_name} log in information' "

      filename ="/var/rails/hmcustomers/app/mail/4wmailer.bat"
      target = open(filename, 'w')
      target.truncate(0)
      line1 = "mail -aFrom:administrator@hansenmueller.com -s "
      line2 = subject
      line3 = mailto
      line4 = " -b avg2fourw@gmail.com </var/rails/hmcustomers/app/mail/mail.txt"
      target.write(line1)
      target.write(line2)
      target.write(line3)
      target.write(line4)
      target.write("\n")
      target.close

      mailfilename ="/var/rails/hmcustomers/app/mail/mail.txt"
      target = open(mailfilename, 'w')
      target.truncate(0)
      line1 = "Hello "
      line2 = @user.first_name
      line3 = ","
      target.write(line1)
      target.write(line2)
      target.write(line3)
      target.write("\n")
      target.write("\n")

      line1 = "Somebody clicked the 'forgot log in' link on "
      line2 = home_url
      line3 = "  using your email address."
      target.write(line1)
      target.write(line2)
      target.write(line3)
      target.write("\n")
      target.write("\n")

      line1 = "Your log in is "
      line2 = @user.web_user_id
      line3 = ". If you forgot your password too, you can reset it here: "
      line4 = new_password_url
      target.write(line1)
      target.write(line2)
      target.write(line3)
      target.write(line4)
      target.write("\n")
      target.write("\n")
      target.close

      val = `/var/rails/hmcustomers/app/mail/4wmailer.bat`
      redirect_to new_session_url, notice: "We emailed you your username!"
    else
      flash[:error] = "Incorrect Email"
      render :new
    end
  end
end
