require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob
    put_customer_into_cookie
  end

  test 'should show profile page' do
    get :show
    assert_response :success
    assert_template 'show'
    assert assigns(:customer)
  end

  test 'should change password' do
    with_transaction_rollback do
      assert WebUser.authenticate('bob', 'bob')
      post :update, :user => { :new_password => 'new_pass', :new_password_confirmation => 'new_pass'}
      assert_response :redirect
      assert_redirected_to home_url

      assert !WebUser.authenticate('bob', 'bob')
      assert WebUser.authenticate('bob', 'new_pass')
    end
  end

  test 'should fail change password' do
    assert WebUser.authenticate('bob', 'bob'), "Pair username/password should be correct"
    post :update, :user => { :new_password => 'new_pass', :new_password_confirmation => 'new_pass_confirm'}
    assert_response :success
    assert_template 'show'
    assert WebUser.authenticate('bob', 'bob')
    assert assigns(:customer)
  end

  test 'should change web_user_id' do
    with_transaction_rollback do
      assert WebUser.authenticate('bob', 'bob'), "Pair username/password should be correct"
      post :update, :user => { :web_user_id => 'new_bob' }

      assert_response :redirect
      assert_redirected_to home_url

      assert !WebUser.authenticate('bob', 'bob')
      assert WebUser.authenticate('new_bob', 'bob')
    end
  end

  test 'should fail change web_user_id with empty value' do
    with_transaction_rollback do
      assert WebUser.authenticate('bob', 'bob'), "Pair username/password should be correct"
      post :update, :user => { :web_user_id => '' }

      assert_response :success
      assert_template 'show'

      assert WebUser.authenticate('bob', 'bob')
    end
  end

  test 'should fail change web_user_id with not unique value' do
    with_transaction_rollback do
      assert WebUser.authenticate('bob', 'bob'), "Pair username/password should be correct"
      new_login = WebUser.find(:first, :conditions => "WebUserId != 'bob'").web_user_id

      post :update, :user => { :web_user_id => new_login }

      assert_response :success
      assert_template 'show'

      assert WebUser.authenticate('bob', 'bob')
    end
  end
end
