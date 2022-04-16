pdf.font 'Courier'
pdf.font_size = 14

pdf.text "#{contract_type(@contract)} CONTRACT", :style => :bold, :size => 14, :align => :center
pdf.text 'TICKET APPLICATIONS', :align => :center

pdf.bounding_box [0, 800], :width => 90, :height => 90 do
  pdf.text @contract.sold? ? 'Sold to:' : 'Purchased from:'
end

pdf.bounding_box [105, 800], :width => 340, :height => 90 do
  pdf.text current_customer.contract_name.blank? ? current_customer.company : current_customer.contract_name
  pdf.text format_address(current_customer.bill || current_customer.ship)
end

pdf.bounding_box [470, 800], :width => 180, :height => 90 do
  pdf.text Hmcustomers.config.company_name
  pdf.text format_address(@contract.hm_office.address)
end

pdf.stroke_horizontal_rule

pdf.bounding_box [0, 705], :width => 400, :height => 120 do
  data = [
    ['Contact:',        "#{@contract.employee.first_last_name}/#{@contract.cust_last_name}"],
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

pdf.bounding_box [350, 703], :width => 80, :height => 75 do
  pdf.text "##{current_customer.cust_id}"
end

grade = @contract.grade


pdf.bounding_box [430, 705], :width => 200, :height => 120 do
  data = [
    ['Date:',        @contract.cont_date.to_s(:report)],
    ['Contract No:', @contract.cont_id],
    ['Your Nubmer:', '']
  ]
  data << ['Grade:', "##{grade.grade_id}"] if grade && !['N/A', 'NA'].include?(grade.grade_id)

  data += [
    [' ', ''],
    [' ', ''],
    [' ', ''],
    ['Unsettled:', "#{@contract.un_settle} #{@contract.unit_type.short_name}"]
  ]

  pdf.table data,
    :border_width => 0,
    :font_size => 14,
    :align => { 0 => :left, 1 => :right },
    :padding => 0,
    :position => :left
end

pdf.move_down 10
pdf.stroke_horizontal_rule
pdf.move_down 5

pdf.text 'Special instructions/Remarks:'
pdf.move_down 10
pdf.text @contract.typed_rmks.to_s

pdf.move_down 10

data = []

gross_lbs_total = 0.00
gross_bu_total  = 0.00
net_lbs_total   = 0.00
net_bu_total    = 0.00

disc_dollars_total          = 0.00
storage_total               = 0.00
tax_amount_total            = 0.00
defer_premium_total         = 0.00
net_dollars_total           = 0.00
payable_dollars_total       = 0.00
payable_dollars_today_total = 0.00

ticket_apps = @pricing ? @pricing.ticket_apps : @contract.ticket_apps

ticket_apps.includes(:cont).each do |ticket_app|
  ticket = ticket_app.ticket

  gross_lbs = ticket_app.gross_lbs
  gross_bu  = ticket_app.gross_units
  net_lbs   = ticket_app.net_lbs
  net_bu    = ticket_app.net_units

  gross_lbs_total += gross_lbs
  gross_bu_total  += gross_bu
  net_lbs_total   += net_lbs
  net_bu_total    += net_bu

  disc_dollars          = ticket_app.disc_dollars
  storage               = (ticket_app.storage || 0.00)
  tax_amount            = ticket_app.tax_amount
  defer_premium         = ticket_app.defer_premium
  net_dollars           = ticket_app.net_dollars
  payable_dollars       = ticket_app.payable_dollars
  payable_dollars_today = ticket_app.payable_dollars_today

  disc_dollars_total          += disc_dollars
  storage_total               += storage
  tax_amount_total            += tax_amount
  defer_premium_total         += defer_premium
  net_dollars_total           += net_dollars
  payable_dollars_total       += payable_dollars
  payable_dollars_today_total += payable_dollars_today

  data << [
    "#{ticket_app.tick_num}#{'\nOverfill' if ticket_app.overfill_apply_type?}",
    "#{ticket_app.dlv_date.to_s(:report_short_year)}\n#{ticket_app.cont.pricing_id}",
    "#{gross_lbs.round(2)}\n#{gross_bu.round(2)}",
    "#{net_lbs.round(2)}\n#{net_bu.round(2)}",
    ticket.lading_num,
    ticket.o_tick_num,
    ticket_app.form_num,
    ticket_app.form_date.to_s(:report_short_year),
    disc_dollars,
    storage,
    tax_amount,
    defer_premium,
    net_dollars,
    payable_dollars,
    payable_dollars_today
  ]
  data << [{:colspan => 15, :text => (ticket_app.misc_remarks || "")}]
end

unless data.empty?
  data << [
    { :text => '**Total**', :colspan => 2},
    "#{gross_lbs_total.round(2)}\n#{gross_bu_total.round(2)}",
    "#{net_lbs_total.round(2)}\n#{net_bu_total.round(2)}",
    "", "", "", "",
    disc_dollars_total,
    storage_total,
    tax_amount_total,
    defer_premium_total,
    net_dollars_total,
    payable_dollars_total,
    payable_dollars_today_total
  ]

  pdf.table data,
    :headers => ["Ticket #", "Date\nPricing #", "Gross Lbs\nGross Bu.", "Net Lbs\nNet Bu.",
                 "Lading\nNumber", "Origin\nTicket #", "Form\nNumber", "Form Date", "Disc\nDollars",
                 "Storage", "Tax\nAmount", "Defer\nPremium", "Net\nDollars", "Payable\nDollars", "Payable\n#{Date.today.to_s(:report_short_year)}"],
    :widths => { 0 => 48, 1 => 58, 2 => 60, 3 => 60, 4 => 45, 5 => 48, 6 => 36, 7 => 48, 8 => 42, 9 => 42, 10 => 35, 11 => 42, 12 => 55, 13 => 55, 14 => 55},
    :align_headers => { 2 => :right, 3 => :right, 7 => :right, 8 => :left, 9 => :left, 10 => :left, 11 => :left, 12 => :left, 13 => :left, 14 => :left },
    :align => { 0 => :left, 1 => :left, 2 => :right, 3 => :right, 6 => :left, 8 => :right, 9 => :right, 10 => :right, 11 => :right, 12 => :right, 13 => :right, 14 => :right },
    :border_style => :underline_header,
    :font_size => 9,
    :horizontal_padding => 2,
    :vertical_padding => 2,
    :position => :left
end
