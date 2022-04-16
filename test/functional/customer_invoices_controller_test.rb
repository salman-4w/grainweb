require 'test_helper'

class CustomerInvoicesControllerTest < ActionController::TestCase
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

  test 'should load invoices' do
    xhr :get, :index, :customer_id => @customer_id, :start => 0, :limit => 1
    assert_response :success
    assert_match /\"total\":\d/, @response.body
  end

  test 'should generate a PDF file' do
    invoice = Invoice.find(1581)
    assert !invoice.nil?, "Invoice should not be null"
    assert !invoice.pdf_data.data.nil?, "Invoice PDF data should not be empty"

    get :print, :customer_id => 'CARSI', :id => invoice.id
    assert_response :success
    assert_match /filename="invoice_#{invoice.form_num}.pdf"/, @response.headers['Content-Disposition']
    assert_equal Mime::PDF.to_s, @response.headers['Content-Type']
  end

  test 'should show a message when no PDF data' do
    invoice = Invoice.find(79647)
    assert invoice.pdf_data.data.nil?
    get :print, :customer_id => @customer_id, :id => invoice.id
    assert_response :not_found
    assert_equal "Invoice ##{invoice.form_num} has nothing to print", @response.body
  end
end
