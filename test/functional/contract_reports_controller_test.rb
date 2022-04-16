require 'test_helper'

class ContractReportsControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob

    @customer_id = 'USGSA'
    @contract_id = '55193'
  end

  test 'should generate pricing PDF' do
    get :pricing, :customer_id => @customer_id, :contract_id => @contract_id, :format => :pdf
    assert_response :success
    assert_template 'pricing'
    assert 'application/pdf', @response.content_type.to_s

    assert_not_nil assigns(:customer)
    assert_not_nil assigns(:contract)
  end

  test 'should generate amendments PDF' do
    get :amendment, :customer_id => @customer_id, :contract_id => @contract_id, :format => :pdf
    assert_response :success
    assert_template 'amendment'
    assert 'application/pdf', @response.content_type.to_s

    assert_not_nil assigns(:customer)
    assert_not_nil assigns(:contract)
  end

  test 'should generate amendment PDF' do
    get :amendment, :customer_id => @customer_id, :contract_id => @contract_id, :amendment_id => '55193||93681', :format => :pdf
    assert_response :success
    assert_template 'amendment'
    assert 'application/pdf', @response.content_type.to_s

    assert_not_nil assigns(:customer)
    assert_not_nil assigns(:contract)
    assert_not_nil assigns(:amendment)
  end

  test 'should generate confirmation PDF' do
    get :confirmation, :customer_id => @customer_id, :contract_id => @contract_id, :format => :pdf
    assert_response :success
    assert_template 'confirmation'
    assert 'application/pdf', @response.content_type.to_s

    assert_not_nil assigns(:customer)
    assert_not_nil assigns(:contract)
  end

  test 'should generate ticket applications PDF' do
    get :ticket_applications, :customer_id => @customer_id, :contract_id => @contract_id, :format => :pdf
    assert_response :success
    assert_template 'ticket_applications'
    assert 'application/pdf', @response.content_type.to_s

    assert_not_nil assigns(:customer)
    assert_not_nil assigns(:contract)
  end

  test 'should generate ticket dollars PDF' do
    get :ticket_dollars, :customer_id => @customer_id, :contract_id => @contract_id, :format => :pdf
    assert_response :success
    assert_template 'ticket_dollars'
    assert 'application/pdf', @response.content_type.to_s

    assert_not_nil assigns(:customer)
    assert_not_nil assigns(:contract)
  end
end
