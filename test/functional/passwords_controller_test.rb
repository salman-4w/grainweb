require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
  test 'should show new page' do
    get :new
    assert_response :success
    assert_template 'new'
  end

  test 'should generate new password, change current password and send it' do
    emails = ActionMailer::Base.deliveries
    emails.clear

    login = 'bob'
    password = 'bob'

    with_transaction_rollback do
      assert WebUser.authenticate(login, password)

      post :create, :login => login
      assert_response :redirect
      assert_redirected_to new_session_url
      assert_equal 'New password was sent to your email.', flash[:notice]

      assert_equal 1, emails.size

      assert !WebUser.authenticate(login, password)
    end
  end

  test 'should show an error for the incorrect login' do
    emails = ActionMailer::Base.deliveries
    emails.clear

    post :create, :login => 'im_not_exist'
    assert_response :success
    assert_template 'new'
    assert emails.empty?
  end
end
