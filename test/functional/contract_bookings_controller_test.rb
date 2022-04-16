require 'test_helper'

class ContractBookingsControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob
    
    @customer_id = 'USGSA'
    @contract_id = '55193'
  end
  
  test 'should render grid' do
    get :list, :customer_id => @customer_id, :contract_id => @contract_id
    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:customer)
    assert_not_nil assigns(:contract)
  end
  
  test 'should load bookings' do
    xhr :get, :index, :customer_id => @customer_id, :contract_id => @contract_id, :start => 0, :limit => 1
    assert_response :success
    assert_match /\"total\":\d/, @response.body
    assert_not_nil assigns(:customer)
    assert_not_nil assigns(:contract)
  end
end
