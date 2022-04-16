module ContractReportsHelper
  def format_address(address)
    formatted_address = address.addr1.to_s
    formatted_address << "\n" unless address.addr1.blank?
    
    formatted_address << address.addr2.to_s
    formatted_address << "\n" unless address.addr2.blank?
    
    formatted_address << "#{address.city} #{address.try(:state).try(:abbrev)} #{address.zip}\n"
    
    formatted_address << "#{address.country}\n" if address.international
    
    formatted_address << number_to_phone(address.phone, area_code: true) unless address.phone.blank?
    
    formatted_address
  end
  
  def date_period(start_at, end_at)
    result = start_at.to_s(:report)
    result << " - #{end_at.to_s(:report)}" if end_at
    result
  end
  
  def contract_type(contract)
    if contract.deferred_pay?
      'DEFERRED'
    elsif contract.purchased?
      'PURCHASE'
    else
      'SALE'
    end
  end
  
  def pricings_array(pricings)
    return '[]' if pricings.blank?
    
    result = '['
    result << pricings.map { |p| "{text: '#{p.pricing_id}', value: '#{p.id}'}" }.join(',')
    result << ']'
    result
  end
end
