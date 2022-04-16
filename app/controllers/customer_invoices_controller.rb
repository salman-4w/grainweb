class CustomerInvoicesController < ApplicationController
  before_filter :login_required
  before_filter :ensure_customer_access

  grid global_filter: [:check_status_filter, :check_commodity_filter],
    association: "current_customer.invoices",
    class_name: "Invoice"

  def print
    invoice = current_customer.invoices.find(params[:id])

    if invoice && pdf_content = invoice.pdf_data.data
      send_data pdf_content, filename: "invoice_#{invoice.form_num}.pdf", type: Mime::PDF.to_s
    else
      render text: "Invoice ##{invoice.form_num} has nothing to print", status: :not_found
    end
  end

  private

  def ensure_customer_access
    redirect_to(home_url) unless current_customer.can_view_invoices?
  end

  def check_status_filter
    status = params[:global_filter].try(:[], :status)
    case status.blank? ? 'unpaid' : status
      when 'unpaid' then [' (CloseDate IS NULL OR CloseDate > {fn NOW()})']
      when 'paid'   then [' CloseDate < {fn NOW()}']
      when 'all'    then nil
    end
  end

  def check_commodity_filter
    commodity = params[:global_filter].try(:[], :commodity)
    case commodity.blank? ? 'all' : commodity
      when 'all' then nil
      else [" Comm->CommName = #{Commodity.quote_value(commodity)}"]
    end
  end
end
