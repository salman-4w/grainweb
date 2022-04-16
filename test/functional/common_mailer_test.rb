require 'test_helper'

class CommonMailerTest < ActionMailer::TestCase
  test "should generate contact us email" do
    user = users(:bob)
    message = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit.'
    email = CommonMailer.contact_us_email(user.id, message)

    assert_equal Hmcustomers.config.contact_email, email.to[0]
    assert_equal 'New message from GrainWeb user', email.subject

    email_body = email.body
    assert email_body.include?(message)
    assert email_body.include?(user.full_name)
    assert email_body.include?(user.email_address)
  end
end
