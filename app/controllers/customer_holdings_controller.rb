class CustomerHoldingsController < ApplicationController
  before_filter :login_required
  before_filter :ensure_customer_access

  grid global_filter: [:check_type_filter, :check_commodity_filter],
    association: "current_customer.holdings",
    class_name: "TicketApp"

  private

  def ensure_customer_access
    redirect_to(home_url) unless current_customer.can_view_holdings?
  end

  def check_type_filter
    type = params[:global_filter].try(:[], :type)
    case type.blank? ? 'purchase' : type
      when 'purchase' then [" PurSale = 'P'"]
      when 'sale' then [" PurSale = 'S'"]
    end
  end

  def check_commodity_filter
    commodity = params[:global_filter].try(:[], :commodity)
    case commodity.blank? ? 'all' : commodity
      when 'all' then nil
      else [" Ticket->Comm->CommName = #{Commodity.quote_value(commodity)}"]
    end
  end
end
