require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob
  end
  
  test 'should show customers list' do
    get :index
    assert_response :success
    assert_template 'index'
    
    selected = assigns(:customer)
    assert_not_nil selected
    
    assert_equal selected, users(:bob).customers.first
    assert_equal selected.cust_id, cookies['selected_customer']
  end
  
  test 'should load one customer' do
    xhr :post, :index, :customer => 'USGSA'
    assert_response :success
    assert_template 'index'
    
    selected = assigns(:customer)
    assert_not_nil selected
    
    assert_equal selected, Customer.find_by_cust_id('USGSA')
    assert_equal selected.cust_id, cookies['selected_customer']
  end
end
