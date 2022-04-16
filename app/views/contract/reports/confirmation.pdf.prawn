pdf.font 'Courier'
pdf.font_size = 14

pdf.text "#{contract_type(@contract)} CONTRACT", :style => :bold, :size => 14, :align => :center
pdf.text 'AND CONFIRMATION', :align => :center

pdf.bounding_box [0, 740], :width => 90, :height => 90 do
  pdf.text @contract.sold? ? 'Sold to:' : 'Purchased from:'
end

pdf.bounding_box [105, 740], :width => 340, :height => 90 do
  pdf.text current_customer.contract_name.blank? ? current_customer.company : current_customer.contract_name
  pdf.text format_address(current_customer.bill || current_customer.ship)
end

pdf.bounding_box [470, 740], :width => 180, :height => 90 do
  pdf.text Hmcustomers.config.company_name
  pdf.text format_address(@contract.hm_office.address)
end

pdf.stroke_horizontal_rule

pdf.bounding_box [350, 642], :width => 80 do
  pdf.text "##{current_customer.cust_id}"
end

pdf.bounding_box [430, 645], :width => 250 do
  pdf.table [
             ['Date:',        @contract.cont_date.to_s(:report)],
             ['Contract No:', @contract.cont_id]
            ],
  :border_width => 0,
  :font_size => 14,
  :align => :left,
  :padding => 0,
  :position => :left
  pdf.text 'Please show on invoice'
  pdf.text 'Your Number:'
end

pdf.bounding_box [0, 595], :width => 300 do
  pdf.text "Contact: #{@contract.employee.first_last_name}/#{@contract.cust_last_name}"
end

pdf.stroke_horizontal_rule

pdf.bounding_box [0, 565], :width => 400, :height => 120 do
  data = [
    ['Commodity:',      @contract.commodity.comm_name],
    ['Quantity/Units:', "#{format_number @contract.qty} #{@contract.unit_type.long_name}"],
    ['Basis:',          @contract.report_basis]
  ]

  unless @contract.deferred_pay?
    data += [
      [@contract.fob? ? 'FOB:' : 'Dlvd:', "#{@contract.location.city_st} - #{@contract.transportation_type.name}"],
      ['Grades:',                         @contract.human_grades],
      ['Weights:',                        @contract.human_weights],
      ['Shipment Period:',                date_period(@contract.ship_start, @contract.ship_end)]
    ]
  end

  pdf.table data,
    :border_width => 0,
    :font_size => 14,
    :align => :left,
    :padding => 0,
    :position => :left
end

grade = @contract.grade

if grade && !['N/A', 'NA'].include?(grade.grade_id)
  pdf.bounding_box [430, 565], :width => 200, :height => 120 do
    pdf.table [['Grade:', "##{grade.grade_id}"]],
      :border_width => 0,
      :font_size => 14,
      :align => { 0 => :left, 1 => :right },
      :padding => 0,
      :position => :left
  end
end

pdf.stroke_horizontal_rule
pdf.move_down 5

@contract.pricings.each do |pricing|
  qty = format_number(pricing.qty)
  unit_short_name = @contract.unit_type.long_name
  price = format_currency(pricing.price)
  basis = format_currency(pricing.basis)
  futures = format_currency(pricing.fut_used)
  date = pricing.price_date.to_s(:report)

  pdf.text "#{qty} #{unit_short_name} priced at #{price}, #{basis} basis, #{futures} futures on #{date}"
end

pdf.move_down 10
pdf.stroke_horizontal_rule
pdf.move_down 5

pdf.text 'Special instructions/Remarks:'
pdf.move_down 10
pdf.text @contract.typed_rmks.to_s

pdf.bounding_box [0, 100], :width => 320, :height => 100 do
  pdf.table [
             ['Accepted', '_____________________'],
             ['By:',      '_____________________'],
             ['Date:',    '_____________________']
            ],
  :border_width => 0,
  :font_size => 14,
  :align => :left,
  :padding => 0,
  :position => :left,
  :widths => { 0 => 110, 1 => 210}
end

pdf.bounding_box [350, 105], :width => 320, :height => 30 do
  pdf.text Hmcustomers.config.company_name
end

pdf.bounding_box [350, 75], :width => 320, :height => 70 do
  pdf.table [
             ['Signed:', '_____________________'],
             ['Date:',    '_____________________']
            ],
  :border_width => 0,
  :font_size => 14,
  :align => :left,
  :padding => 0,
  :position => :left,
  :widths => { 0 => 110, 1 => 210}
end
