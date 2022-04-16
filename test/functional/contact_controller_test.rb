require 'test_helper'

class ContactControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob
    put_customer_into_cookie
  end

  test "should show contact us page" do
    get :show
    assert_response :success
    assert_template 'show'
    assert assigns(:customer)
  end

  test "should send an email" do
    emails = ActionMailer::Base.deliveries
    emails.clear

    message = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit."
    post :create, :message => message
    assert_response :redirect
    assert_redirected_to home_url

    assert_equal 'Email was successfully sent', flash[:notice]
    assert_equal 1, emails.size
  end

  test "should not send an email when message was empty" do
    post :create, :message => ''
    assert_response :success
    assert_template 'show'
  end
end
