require 'test_helper'

# Override find_customer method to not use cookies when testing
LadingsController.class_eval do
  def find_customer
    @customer = if params[:customer_id].blank?
      current_user.customers.find(:first)
    else
      current_user.customers.find_by_cust_id(params[:customer_id])
    end
  end
end

class LadingsControllerTest < ActionController::TestCase
  def setup
    super
    login_as :bob

    @customer_id = 'HMCB'
  end

  test 'should show index page' do
    get :index, :customer_id => @customer_id
    assert_response :success
    assert_template 'index'
  end

  test 'should show edit page' do
    get :edit, :customer_id => @customer_id, :id => customers(@customer_id).pending_ladings.find(:first, :conditions => { :draft => true}).id
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:lading)
  end

  test 'should load pending ladings' do
    xhr :get, :index, :customer_id => @customer_id, :start => 0, :limit => 1
    assert_response :success
    assert_match /\"total\":\d/, @response.body
  end

  test 'should show new pending lading form' do
    get :new, :customer_id => @customer_id
    assert_response :success
    assert_template 'new'
    assert assigns(:lading)
  end

  test 'should create new pending lading' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        post :create, :customer_id => @customer_id, :lading => {
          :draft => false,
          :lading_date => "06/12/2009",
          :contract_number => "170954",
          :grain_loaded => 12,
          :load_tick_num => "343434",

          :tractor_license_num => '123456',
          :trailer_license_num => '654321',

          :driver_license_num => "341341",
          :driver_name => "Bill",
          :carr_id => "HMCB",
          :driver_license_state => "AL",

          :load_tare_weight => 1,
          :load_gross_weight => 1,
          :load_bus_weight => 1,
          :load_net_weight => 1
        }
        assert_response :redirect
        assert_redirected_to customer_ladings_url(assigns(:customer))

        lading = PendingLading.find(:last)

        assert !lading.draft
        message = "Your lading has successfully been submitted for review. Thanks!"
        assert_equal message, flash[:notice]

        assert_not_nil lading.shipper_customer
        assert_not_nil lading.commodity
        assert_not_nil lading.contract

        assert_equal '123456', lading.tractor_license_num
        assert_equal '654321', lading.trailer_license_num
      end
    end
  end

  test 'should create new pending lading with minimum required fields' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        post :create, :customer_id => @customer_id, :lading => {
          :draft => false,
          :lading_date => "06/12/2009",
          :grain_loaded => 12
        }
        assert_response :redirect
        assert_redirected_to customer_ladings_url(assigns(:customer))

        lading = PendingLading.find(:last)

        assert !lading.draft
        message = "Your lading has successfully been submitted for review. Thanks!"
        assert_equal message, flash[:notice]
        assert_equal lading.id, flash[:lading_to_print]

        assert_not_nil lading.shipper_customer
        assert_not_nil lading.commodity
      end
    end
  end

  test 'should create new draft pending lading' do
    with_transaction_rollback do
      assert_difference 'PendingLading.count' do
        post :create, :customer_id => @customer_id, :lading => { :draft => "true" }
        assert_response :redirect

        lading = PendingLading.find(:last)

        assert_redirected_to customer_ladings_url(assigns(:customer))

        assert lading.draft
        assert_equal "Lading was successfully saved.", flash[:notice]
        assert_nil flash[:lading_to_print]
      end
    end
  end

  test 'should destroy draft pending lading' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        xhr :post, :destroy, :customer_id => @customer_id, :id => customers(@customer_id).pending_ladings.find_by_draft(true).id
        assert_response :success
        assert_template nil
        assert PendingLading.find(assigns(:lading).id).deleted
      end
    end
  end

  test 'should not destroy not draft pending lading' do
    with_transaction_rollback do
      assert_no_difference 'PendingLading.count' do
        xhr :post, :destroy, :customer_id => @customer_id, :id => customers(@customer_id).pending_ladings.find_by_draft(false).id
        assert_response :success
        assert_template nil
      end
    end
  end

  test 'should show ladings request page' do
    get :requests, :customer_id => @customer_id
    assert_response :success
    assert_template 'requests'
    assert_not_nil assigns(:customer)
  end

  test 'should send ladings request' do
    emails = ActionMailer::Base.deliveries
    emails.clear

    amount = '50'
    address = 'just a test address'

    post :requests, :customer_id => @customer_id, :amount => amount, :address => address
    assert_response :redirect
    assert_redirected_to customers_url

    assert_equal 1, emails.size
    email = emails.first
    assert_equal 'Lading requests', email.subject
    assert_equal Hmcustomers.config.system_email, email.from[0]
    assert_equal Hmcustomers.config.lading_requests_email, email.to[0]
    assert email.body.include?(amount)
    assert email.body.include?(address)
  end

  test 'should generate pending lading PDF' do
    lading = customers(@customer_id).pending_ladings.find_by_draft(false)

    get :print, :customer_id => @customer_id, :id => lading.id, :format => :pdf
    assert_response :success
    assert_template 'print'
    assert 'application/pdf', @response.content_type.to_s

    assert_match Regexp.new("filename=lading_#{lading.lading_num}"), @response.headers['Content-Disposition']

    assert_not_nil assigns(:customer)
    assert_not_nil assigns(:lading)
  end

  test 'should generate PDF for lading with minimum required data' do
    with_transaction_rollback do
      customer = customers(@customer_id)
      lading = PendingLading.create(:lading_date => Date.today, :shipper_customer => customer, :draft => false, :grain_loaded => 16)

      get :print, :customer_id => @customer_id, :id => lading.id, :format => :pdf
      assert_response :success
      assert_template 'print'
      assert 'application/pdf', @response.content_type.to_s
    end
  end
end
