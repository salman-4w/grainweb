module LadingsHelper
  def commodities_for_select(customer)
    all = Commodity.for_select.map { |comm| [comm.comm_name, comm.id, false] }
    # get commodities that in customer's list of open contracts
    used = Commodity.for_select.where(["(SELECT COUNT(%Id) FROM HM.Contract WHERE Cust = ? AND UnSettle > 0 AND Comm = Commodity.%Id) > 0", customer.id]).map(&:id)

    all.each { |data| data[2] = true if used.include?(data[1]) }
  end

  def open_contract_numbers_for_select(customer)
    customer.contracts.select(:cont_id).where("UnSettle > 0").map { |cont| cont.cont_id }
  end
end
