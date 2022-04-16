require 'test_helper'

class LoginsControllerTest < ActionController::TestCase
  test 'should show new page' do
    get :new
    assert_response :success
    assert_template 'new'
  end

  test 'should send login for the correct email address' do
    emails = ActionMailer::Base.deliveries
    emails.clear

    bob = users(:bob)
    post :create, :email => bob.email_address
    assert_response :redirect
    assert_redirected_to new_session_url
    assert_equal 1, emails.size
  end

  test 'should show an error for the incorrect email address' do
    emails = ActionMailer::Base.deliveries
    emails.clear

    post :create, :email => 'not_existent@email.com'
    assert_response :success
    assert_template 'new'
    assert_equal 'Incorrect Email', flash[:error]

    assert emails.empty?
  end
end
