class CustomerChecksController < ApplicationController
  before_filter :login_required
  before_filter :ensure_customer_access

  grid global_filter: :check_commodity_filter,
    association: "current_customer.checks",
    class_name: "GrnCheck"

  def print
    check = current_customer.checks.find(params[:id])

    if check && pdf_content = check.pdf_data.data
      send_data pdf_content, filename: "check_#{check.form_num}.pdf", type: Mime::PDF.to_s
    else
      render text: "Check ##{check.form_num} has nothing to print", status: :not_found
    end
  end

  private

  def ensure_customer_access
    redirect_to(home_url) unless current_customer.can_view_checks?
  end

  def check_commodity_filter
    commodity = params[:global_filter].try(:[], :commodity)
    case commodity.blank? ? 'all' : commodity
      when 'all' then nil
      else [" Comm->CommName = #{Commodity.quote_value(commodity)}"]
    end
  end
end
