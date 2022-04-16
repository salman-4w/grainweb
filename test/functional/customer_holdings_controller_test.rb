require 'test_helper'

class CustomerHoldingsControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob
    
    @customer_id = 'HMCB'
  end
  
  test 'should show index page' do
    get :index, :customer_id => @customer_id
    assert_response :success
    assert_template 'index'
  end
  
  test 'should load holdings' do
    xhr :get, :index, :customer_id => @customer_id, :start => 0, :limit => 1
    assert_response :success
    assert_match /\"total\":\d/, @response.body
  end
end
