require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  test 'should login and redirect' do
    post :create, :login => 'bob', :password => 'bob'
    assert session[:user_id]
    assert_response :redirect
  end

  test 'should fail login and not redirect' do
    post :create, :login => 'bob', :password => 'bad password'
    assert_nil session[:user_id]
    assert_response :success
  end

  test 'should logout' do
    login_as :bob
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  test 'should redirected to profile page after the first login' do
    bob = WebUser.find_by_web_user_id('bob')
    bob.is_first_login = true
    bob.save

    post :create, :login => 'bob', :password => 'bob'
    assert session[:user_id]
    assert_response :redirect
    assert_redirected_to profile_url
    assert !WebUser.find_by_web_user_id('bob').is_first_login
    assert_equal "Welcome. Please customize your login and password at this time.", flash[:notice]
  end

  # TODO: uncomment following methods for 'remeber me' functionality
  # def test_should_remember_me
#     @request.cookies["auth_token"] = nil
#     post :create, :login => 'bob', :password => 'bob', :remember_me => "1"
#     assert_not_nil @response.cookies["auth_token"]
#   end

  # def test_should_not_remember_me
#     @request.cookies["auth_token"] = nil
#     post :create, :login => 'bob', :password => 'bob', :remember_me => "0"
#     puts @response.cookies["auth_token"]
#     assert @response.cookies["auth_token"].blank?
#   end

  # def test_should_login_with_cookie
#     users(:bob).remember_me
#     @request.cookies["auth_token"] = cookie_for(:bob)
#     get :new
#     assert @controller.send(:logged_in?)
#   end

  # def test_should_fail_expired_cookie_login
#     users(:bob).remember_me
#     users(:bob).update_attribute :remember_token_expires_at, 5.minutes.ago
#     @request.cookies["auth_token"] = cookie_for(:bob)
#     get :new
#     assert !@controller.send(:logged_in?)
#   end

#   def test_should_fail_cookie_login
#     users(:bob).remember_me
#     @request.cookies["auth_token"] = auth_token('invalid_auth_token')
#     get :new
#     assert !@controller.send(:logged_in?)
#   end

  test 'should delete token on logout' do
    login_as :bob
    get :destroy
    assert cookies["auth_token"].blank?
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end

    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
