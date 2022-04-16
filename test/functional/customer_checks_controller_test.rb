require 'test_helper'

class CustomerChecksControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob

    @customer_id = 'USGSA'
  end

  test 'should show index page' do
    get :index, :customer_id => @customer_id
    assert_response :success
    assert_template 'index'
  end

  test 'should load checks' do
    xhr :get, :index, :customer_id => @customer_id, :start => 0, :limit => 1
    assert_response :success
    assert_match /\"total\":\d/, @response.body
  end

  test 'should generate a PDF file' do
    check = GrnCheck.find(8967)
    get :print, :customer_id => @customer_id, :id => 8967
    assert_response :success
    assert_match /filename="check_#{check.form_num}.pdf"/, @response.headers['Content-Disposition']
    assert_equal Mime::PDF.to_s, @response.headers['Content-Type']
  end

  test 'should show a message when no PDF data' do
    check = GrnCheck.find(113)
    assert check.pdf_data.data.nil?
    get :print, :customer_id => 'HMCB', :id => check.id
    assert_response :not_found
    assert_equal "Check ##{check.form_num} has nothing to print", @response.body
  end
end
