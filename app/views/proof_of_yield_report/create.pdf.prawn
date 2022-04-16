pdf.font "Courier"
pdf.font_size = 14

pdf.bounding_box [0, 650], :width => 90 do
  pdf.text Date.today.to_s(:report_with_dash), :align => :left
end

pdf.bounding_box [100, 650], :width => 750 do
  pdf.text Hmcustomers.config.company_name, :align => :center
end

pdf.text "Purchase Delivery Statement", :align => :center
pdf.text @report.commodity.comm_disp, :align => :center
pdf.text "Selected #{@report.start_date.to_s(:report)} to #{@report.end_date.to_s(:report)}", :align => :center, :size => 10

pdf.bounding_box [50, 550], :width => 250 do
  pdf.text @report.cust_id, :align => :center
  if @report.data_grouped_by_customer.size == 1
    pdf.text @report.data_grouped_by_customer.first["company"], :align => :center
  else
    pdf.text "#{@report.last_names.join(",")}*#{@report.commodity.comm_id}*", :align => :center
    pdf.text "#{@report.first_names.join(",")}*#{@report.commodity.comm_name}*", :align => :center
  end
end

pdf.move_down 50

net_units_total    = 0.00
tw_weighted_total  = 0.00
mst_weighted_total = 0.00
dmg_weighted_total = 0.00
fm_weighted_total  = 0.00
spl_weighted_total = 0.00
data_by_ticket     = []
data_by_customer   = []

@report.data_grouped_by_ticket.each do |row|
  ticket = @report.tickets[row["ticket_num"]]

  net_units = ticket.net_units
  net_units_total += net_units

  tw   = ticket.discount_value("TW")
  mst  = ticket.discount_value("Mst")
  dmg  = ticket.discount_value("Dmg")
  fm   = ticket.discount_value("FM")
  spl  = ticket.discount_value("Spl")
  htdg = ticket.discount_value("HtDg")

  tw_weighted_total  += tw * net_units
  mst_weighted_total += mst * net_units
  dmg_weighted_total += dmg * net_units
  fm_weighted_total  += fm * net_units
  spl_weighted_total += spl * net_units

  data_by_ticket << [
    row["ticket_num"],
    row["dlv_date"].to_s(:report_short_year),
    round_to(2, row["sum_gross"]),
    round_to(2, row["sum_gross_net"]),
    round_to(2, row["sum_net"]),
    round_to(2, row["sum_net_netstor"]),
    round_to(2, row["sum_netstor"]),
    round_to(1, tw),
    round_to(1, mst),
    round_to(1, dmg),
    round_to(1, fm),
    round_to(1, spl),
    round_to(1, htdg),
    round_to(2, row["grain_disc"].to_f)
  ]

  # add ticket remarks under the ticket date
  data_by_ticket << (['', ticket.remarks] + [''] * 12)
end

# add 3 lines separator
data_by_ticket << ([""] * 14)
data_by_ticket << ([""] * 14)
data_by_ticket << ([""] * 14)

data_by_customer += @report.data_grouped_by_customer.map do |row|
  [
    row["cust_id"],
    wrap_string(row["company"], 15),
    round_to(2, row["sum_gross"]),
    round_to(2, row["sum_gross_net"]),
    round_to(2, row["sum_net"]),
    round_to(2, row["sum_net_netstor"]),
    round_to(2, row["sum_netstor"]),
    "", "", "", "", "", "",
    round_to(2, row["grain_disc"].to_f)
  ]
end

data_by_customer << ["", "TOTALS",
         round_to(2, data_by_customer.sum {|x| x[2].to_f }), # gross bushels
         round_to(2, data_by_customer.sum {|x| x[3].to_f }), # dock bushels
         round_to(2, data_by_customer.sum {|x| x[4].to_f }), # net bushels
         round_to(2, data_by_customer.sum {|x| x[5].to_f }), # storage shrink
         round_to(2, data_by_customer.sum {|x| x[6].to_f }), # net storage bushels
         round_to(1, weighted_total(tw_weighted_total, net_units_total)),
         round_to(1, weighted_total(mst_weighted_total, net_units_total)),
         round_to(1, weighted_total(dmg_weighted_total, net_units_total)),
         round_to(1, weighted_total(fm_weighted_total, net_units_total)),
         round_to(1, weighted_total(spl_weighted_total, net_units_total)),
         "", ""]

pdf.table (data_by_ticket + data_by_customer),
  :headers => ["Ticket #", "Date", "Gross Bu.", "Doc Bu.", "Net Bu.", "Stor Shrink", "Net Stor Bu.",
               "TW", "Mst", "Dmg", "FM", "Spl", "HtDg", "Disc."],
  :column_widths => { 0 => 70, 1 => 70, 2 => 70, 3 => 70, 4 => 70, 5 => 80, 6 => 90, 7 => 50, 8 => 60, 9 => 50, 10 => 50, 11 => 50, 12 => 50, 13 => 50 },
  :align => { 0 => :left, 1 => :left, 2 => :right, 3 => :right, 4 => :right, 5 => :right, 6 => :right, 7 => :right, 8 => :right, 9 => :right, 10 => :right, 11 => :right, 12 => :right, 13 => :right },
  :border_style => :underline_header,
  :font_size => 10,
  :horizontal_padding => 2,
  :vertical_padding => 2,
  :position => :left
