module ContractsHelper
  def link_to_pricing(contract)
    result = '<span style="'
    result << 'border:0 none;margin:0;padding:0;height:18px;width:16px;vertical-align:top;cursor:pointer;'
    result << '">'
    result << '<img src="/images/plus.gif" style="vertical-align: middle;"/>'
    result << '</span>'
    result
  end
end
