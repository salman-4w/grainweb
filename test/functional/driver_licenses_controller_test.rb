require 'test_helper'

class DriverLicensesControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob
  end
  
  test 'should find driver license' do
    license_num = PendingLading.find(:first).driver_license_num
    xhr :get, :search, :id => license_num
    assert_response :success
    assert_template nil
    assert /^\{.*\}$/, @response.body
  end
  
  test 'should return 404 for not existent license' do
    xhr :get, :search, :id => 'INVALID'
    assert_response :not_found
    assert_template nil
  end
end
