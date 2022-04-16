require 'test_helper'

class LadingMailerTest < ActionMailer::TestCase
  test "should generate requests email" do
    amount = "99.55"
    address = "30 Rock"
    email = LadingMailer.requests_email(amount, address)

    assert_equal Hmcustomers.config.lading_requests_email, email.to[0]
    assert_equal 'Lading requests', email.subject

    email_body = email.body
    assert email_body.include?(amount)
    assert email_body.include?(address)
  end
end
