class ContractsController < ApplicationController
  before_filter :login_required

  grid global_filter: [:grid_type_filter, :grid_status_filter, :grid_commodity_filter],
    association: "current_customer.contracts.without_deferred",
    finder: {select: [:id, :cont_id, :ship_start, :qty, :price_type,
      :cont_price, :basis, :un_priced_qty, :un_settle, :cont_date, :fob_delv,
      :pur_sale]}

  def show
    @contract = current_customer.contracts.find(params[:id])
    render layout: false
  end

  def search
    @contract = current_customer.contracts.find_by_cont_id(params[:id])
    if @contract.nil?
      render text: "Not found", status: :not_found
    else
      text_to_render = @contract.fob? ? @contract.location.to_s : current_customer.ship.to_s
      render text: text_to_render
    end
  end

  private

  def grid_type_filter
    type = params[:global_filter].try(:[], :type)
    case type.blank? ? 'purchase' : type
      when 'purchase' then [" PurSale = 'P'"]
      when 'sale' then [" PurSale = 'S'"]
    end
  end

  def grid_status_filter
    status = params[:global_filter].try(:[], :status)
    case status.blank? ? 'open' : status
      when 'open' then [' UnSettle > 0']
      when 'closed' then [' UnSettle <= 0']
      when 'all' then nil
    end
  end

  def grid_commodity_filter
    commodity = params[:global_filter].try(:[], :commodity)
    case commodity.blank? ? 'all' : commodity
      when 'all' then nil
      else [" Comm->CommName = #{Commodity.quote_value(commodity)}"]
    end
  end
end
