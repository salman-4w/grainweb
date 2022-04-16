class ApplicationController < ActionController::Base
  protect_from_forgery

  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  helper_method :save_customers_in_cookie

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # secret: '599a2ac97e8edd0a206e9110c3cb7dcf'

  # rescue_from Intersys::ConnectionError, with: :connection_error

  # default settings for generated PDF files
  prawnto prawn: {
    left_margin: 35,
    right_margin: 35,
    top_margin: 80,
    bottom_margin: 80,
    page_layout: :portrait,
    page_size: [779.04, 1008],
  }, inline: false

  protected

  def ssl_required?
    Rails.env.production?
  end

  def save_customers_in_cookie
    return unless logged_in?

    customers = current_user.customers.map(&:cust_id)
    cookies[:customers_for_select] = customers.join('&')
    customers
  end

  def connection_error(exception)
    logger.error "Problems with database connection: #{exception}"
    render_500_error
  end

  def render_500_error
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/500.html", status: 500 }
      format.xml  { render nothing: true, status: 500 }
    end
  end
end
