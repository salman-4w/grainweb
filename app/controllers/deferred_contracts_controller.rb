class DeferredContractsController < ContractsController
  before_filter :login_required

  grid global_filter: [:grid_type_filter, :grid_status_filter, :grid_commodity_filter],
    association: "current_customer.contracts.deferred",
    class_name: "Contract",
    finder: {select: [:id, :cont_id, :ship_start, :qty, :price_type,
      :cont_price, :basis, :un_priced_qty, :un_settle, :cont_date, :fob_delv,
      :pur_sale]}

  private

  def grid_type_filter
    type = params[:global_filter].try(:[], :type)
    case type.blank? ? "purchase" : type
      when "purchase" then [" PurSale = 'P'"]
      when "sale" then [" PurSale = 'S'"]
    end
  end

  def grid_status_filter
    status = params[:global_filter].try(:[], :status)
    case status.blank? ? "open" : status
      when "open" then [" Unprocessed > 0"]
      when "closed" then [" Unprocessed <= 0"]
      when "all" then nil
    end
  end

  def grid_commodity_filter
    commodity = params[:global_filter].try(:[], :commodity)
    case commodity.blank? ? "all" : commodity
      when "all" then nil
      else [" Comm->CommName = #{Commodity.quote_value(commodity)}"]
    end
  end
end
