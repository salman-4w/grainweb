require 'test_helper'

class ContractsControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob
    
    @customer_id = 'USGSA'
    @contract_id = '55193'
  end
  
  test 'should show index page' do
    get :index, :customer_id => @customer_id
    assert_response :success
    assert_template 'index'
  end
  
  test 'should load contracts' do
    xhr :get, :index, :customer_id => @customer_id, :start => 0, :limit => 1
    assert_response :success
    assert_match /\"total\":\d/, @response.body
  end
  
  test 'should show contract' do
    xhr :get, :show, :customer_id => @customer_id, :id => @contract_id
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:contract)
  end
  
  test 'should find contract and return it location' do
    contract = Contract.find_by_cont_id('170954')
    assert contract.fob?
    
    xhr :get, :search, :customer_id => @customer_id, :id => contract.cont_id
    assert_response :success
    assert_template nil
    assert_equal contract.location.to_s, @response.body
  end
  
  test 'should find contract and return customer location' do
    contract = Contract.find_by_cont_id('167514')
    assert !contract.fob?
    
    xhr :get, :search, :customer_id => @customer_id, :id => contract.cont_id
    assert_response :success
    assert_template nil
    assert_equal customers(@customer_id).ship.to_s, @response.body
  end
  
  test 'should return 404 for not existent contracts' do
    xhr :get, :search, :customer_id => @customer_id, :id => 'INVALID'
    assert_response :not_found
    assert_template nil
  end
end
