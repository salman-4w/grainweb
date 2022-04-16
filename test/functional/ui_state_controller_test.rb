require 'test_helper'

class UiStateControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob
  end
  
  test 'should render UI state' do
    xhr :get, :show
    assert_response :success
    assert_match /^\{.*\}$/, @response.body
  end
  
  test 'should update UI state' do
    with_transaction_rollback do
      xhr :post, :update, :name => 'test', :value => '{"t1": 42}'
      assert_response :success
      assert_template nil
      
      assert_match /"test"\:\{"t1":42\}/, users(:bob).ui_state
    end
  end
  
  test 'should destroy UI state' do
    with_transaction_rollback do
      xhr :post, :destroy
      assert_response :success
      assert_template nil
      assert users(:bob).ui_state.blank?
    end
  end
end
