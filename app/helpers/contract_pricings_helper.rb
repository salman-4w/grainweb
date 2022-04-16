module ContractPricingsHelper
  def format_number(number)
    number_with_delimiter(number_with_precision(number, precision: 2))
  end
  
  def format_currency(number)
    number_to_currency(number, precision: 4)
  end
end
