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

tw_weighted_total   = 0.00
mst_weighted_total  = 0.00
htdg_weighted_total = 0.00
fm_weighted_total   = 0.00
sco_weighted_total  = 0.00
bly_weighted_total  = 0.00
thn_weighted_total  = 0.00
wo_weighted_total   = 0.00
wht_weighted_total  = 0.00
dmg_weighted_total  = 0.00

ticket_apps = @pricing ? @pricing.ticket_apps : @contract.ticket_apps

ticket_apps.includes(:ticket).each do |ticket_app|
  ticket = ticket_app.ticket

  gross_lbs = ticket_app.gross_lbs
  gross_bu  = ticket_app.gross_units
  net_lbs   = ticket_app.net_lbs
  net_bu    = ticket_app.net_units

  gross_lbs_total += gross_lbs
  gross_bu_total  += gross_bu
  net_lbs_total   += net_lbs
  net_bu_total    += net_bu

  tw   = ticket.discount_value('TW')
  mst  = ticket.discount_value('Mst')
  htdg = ticket.discount_value('HtDg')
  fm   = ticket.discount_value('FM')
  sco  = ticket.discount_value('Sco')
  bly  = ticket.discount_value('Bly')
  thn  = ticket.discount_value('Thn')
  wo   = ticket.discount_value('WO')
  wht  = ticket.discount_value('Wht')
  dmg  = ticket.discount_value('Dmg')

  tw_weighted_total   += tw * gross_lbs
  mst_weighted_total  += mst * gross_lbs
  htdg_weighted_total += htdg * gross_lbs
  fm_weighted_total   += fm * gross_lbs
  sco_weighted_total  += sco * gross_lbs
  bly_weighted_total  += bly * gross_lbs
  thn_weighted_total  += thn * gross_lbs
  wo_weighted_total   += wo * gross_lbs
  wht_weighted_total  += wht * gross_lbs
  dmg_weighted_total  += dmg * gross_lbs

  data << [
    "#{ticket_app.tick_num}#{'\nOverfill' if ticket_app.overfill_apply_type?}",
    "#{ticket_app.dlv_date.to_s(:report_short_year)}\n#{ticket_app.cont.pricing_id}",
    "#{gross_lbs.round(2)}\n#{gross_bu.round(2)}",
    "#{net_lbs.round(2)}\n#{net_bu.round(2)}",
    "#{ticket.carrier_id}\n#{ticket_app.price}",
    ticket.lading_num,
    ticket.o_tick_num,
    ticket_app.form_num,
    ticket_app.form_date.to_s(:report_short_year),
    tw,
    mst,
    htdg,
    fm,
    sco,
    bly,
    thn,
    wo,
    wht,
    dmg
  ]
  data << [{:colspan => 19, :text => (ticket_app.misc_remarks || "")}]
end

unless data.empty?
  data << [
    {text: "**Total**", colspan: 2},
    "#{gross_lbs_total.round(2)}\n#{gross_bu_total.round(2)}",
    "#{net_lbs_total.round(2)}\n#{net_bu_total.round(2)}",
    "", "", "", "", "",
    (tw_weighted_total/gross_lbs_total).round(2),
    (mst_weighted_total/gross_lbs_total).round(2),
    (htdg_weighted_total/gross_lbs_total).round(2),
    (fm_weighted_total/gross_lbs_total).round(2),
    (sco_weighted_total/gross_lbs_total).round(2),
    (bly_weighted_total/gross_lbs_total).round(2),
    (thn_weighted_total/gross_lbs_total).round(2),
    (wo_weighted_total/gross_lbs_total).round(2),
    (wht_weighted_total/gross_lbs_total).round(2),
    (dmg_weighted_total/gross_lbs_total).round(2)
  ]

  pdf.table data,
    :headers => ["Ticket #", "Date\nPricing #", "Gross Lbs\nGross Bu.", "Net Lbs\nNet Bu.",
                 "Carrier/\nPrice", "Lading\nNumber", "Origin\nTicket #", "Form\nNumber", "Form Date", "TW",
                 "Mst", "HtDg", "FM", "Sco", "Bly", "Thn", "WO", "Wht", "Dmg"],
    :widths => { 0 => 52, 1 => 60, 2 => 62, 3 => 60, 4 => 52, 5 => 52, 6 => 52, 7 => 40, 8 => 52, 9 => 22, 10 => 25, 11 => 30, 12 => 25, 13 => 25, 14 => 25, 15 => 25, 16 => 25, 17 => 25, 18 => 25 },
    :align_headers => { 2 => :right, 3 => :right, 4 => :left, 9 => :right, 10 => :right, 12 => :right, 13 => :right },
    :align => { 0 => :left, 1 => :left, 2 => :right, 3 => :right, 4 => :right, 7 => :left, 9 => :right, 10 => :right, 12 => :right, 13 => :right },
    :border_style => :underline_header,
    :font_size => 9,
    :horizontal_padding => 2,
    :vertical_padding => 2,
    :position => :left
end
