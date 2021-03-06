module ReportsHelper
  def customer_split_codes_for_select(customer)
    [customer.cust_id] + Customer.connection.select_values("SELECT Cust->CustId FROM HM.CustSplit WHERE CustomerId->CustId = #{Customer.connection.quote(customer.cust_id)} and CustomerId->CustId = #{Customer.connection.quote(customer.cust_id)}  ORDER BY Cust->CustId")
  end

  def all_commodities_for_select
    Commodity.for_select.map { |comm| comm.comm_name }
  end

  def weighted_total(weight, total)
    return 0.00 if weight.zero? || total.zero?
    (weight/total).round(1)
  end

  def wrap_string(s, width=78)
    s.gsub(/(.{1,#{width}})(\s+|\Z)/, "\\1\n")
  end

  def round_to(n, original)
    sprintf("%.#{n}f", original)
  end
end
