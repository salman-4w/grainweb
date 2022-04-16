class HomeController < ApplicationController
  before_filter :login_required

  def index
    # allow for switching of customer
    if params[:customer].present?
      if new_customer = current_user.customers.find_by_cust_id(params[:customer])
        self.current_customer = new_customer
      end
    end

    respond_to do |format|
      format.html
      format.js
    end
  end
end
