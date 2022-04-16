require 'test_helper'

class LanesMapControllerTest < ActionController::TestCase
  test 'should show map' do
    get :index
    assert_response :success
    assert_template 'index'
  end
end
