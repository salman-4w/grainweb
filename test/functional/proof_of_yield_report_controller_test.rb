require 'test_helper'

class ProofOfYieldReportControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob
    put_customer_into_cookie
  end

  test 'should render report form page' do
    get :show
    assert_response :success
    assert_template 'show'

    assert assigns(:customer)
  end

  test 'should generate report PDF' do
    post :create, :report => {
      :cust_id => "0008AC",
      :comm_name => "Soybeans",
      :start_date => "01/01/2011",
      :end_date => "02/02/2011"
    }, :format => :pdf

    assert_not_nil assigns(:report)

    assert_response :success
    assert_template 'create'
    assert 'application/pdf', @response.content_type.to_s
    assert_match /filename=proof_of_yield.pdf/, @response.headers['Content-Disposition']
  end
end
