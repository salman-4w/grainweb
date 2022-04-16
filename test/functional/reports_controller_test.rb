require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob
    put_customer_into_cookie
  end

  test 'should render index page' do
    get :index
    assert_response :success
    assert_template 'index'

    assert assigns(:customer)
  end
end
