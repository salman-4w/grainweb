ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  #fixtures :all

  # Add more helper methods to be used by all tests here...

  include AuthenticatedTestHelper

  def users(name)
    WebUser.find_by_web_user_id(name.to_s)
  end

  def customers(customer_id)
    Customer.find_by_cust_id(customer_id)
  end

  def with_transaction_rollback(&block)
    Intersys::Object.database.start
    begin
      yield
    ensure
      Intersys::Object.database.rollback
    end
  end

  # imitate customer id in cookie
  def put_customer_into_cookie
    @request.cookies['selected_customer'] = CGI::Cookie.new('name' => 'selected_customer', 'value' => 'USGSA')
  end
end

# Stub ssl_request? method to prevent exception in tests
Prawnto::TemplateHandler::CompileSupport.class_eval do
  def ssl_request?
    false
  end
end
