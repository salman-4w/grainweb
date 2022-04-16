require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "should generate forgot login email" do
    user = users('bob')
    email = UserMailer.forgot_login_email(user.id)

    assert_equal user.email_address, email.to[0]
    assert email.body.include?(user.web_user_id)
  end

  test "should generate new password email" do
    user = users('bob')
    password = 'NEWPASSWORD'
    email = UserMailer.new_password_email(user.id, password)

    assert_equal user.email_address, email.to[0]
    assert email.body.include?(password)
  end
end
