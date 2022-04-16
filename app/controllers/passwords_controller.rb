class PasswordsController < ApplicationController
  def new
    render
  end

  def create
    if user = WebUser.find_by_web_user_id(params[:login])
      user.forgot_password!

      @user = WebUser.find(user.id)
      @new_password = user.new_password
      mailto = @user.email_address
      subject = "'Your new #{Hmcustomers.config.company_name} password' "

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
      line4 = home_url
      line5 = profile_url
      target.write(line1)
      target.write(line2)
      target.write(line3)
      target.write("\n")
      target.write("\n")

      line1 = "Somebody clicked the 'forgot password' link on "
      line2 = home_url
      line3 = "  using your username."
      target.write(line1)
      target.write(line2)
      target.write(line3)
      target.write("\n")
      target.write("\n")

      line1 = "Your new temporary password is: "
      line2 = @new_password
      target.write(line1)
      target.write(line2)
      target.write("\n")
      target.write("\n")

      line1 = "After logging in with the temporary password, you can set a new password on the profile page: "
      line2 = profile_url
      target.write(line1)
      target.write(line2)
      target.write("\n")
      target.close

      val = `/var/rails/hmcustomers/app/mail/4wmailer.bat`
      redirect_to new_session_url, notice: "We emailed you a New password!"
    else
      flash[:error] = "Incorrect Username"
      render :new
    end
  end
end
