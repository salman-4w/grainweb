default_table_options = {
  :border_width => 0,
  :font_size => 14,
  :align => :left,
  :vertical_padding => 0,
  :horizontal_padding => 5,
  :position => :left
}

pdf.font 'Courier'
pdf.font_size = 14

pdf.text "PENDING LADING", :style => :bold, :size => 14, :align => :center


pdf.draw_text "Shipped From", :at => [0, 800], :style => :bold

pdf.indent(20) do
  pdf.bounding_box [0, 790], :height => 120, :width => 700 do
    data = [
            ['Lading Num:', @lading.lading_num],
            ['Lading Date:', @lading.lading_date.to_s(:report)],
            ['Shipper:', @lading.shipper],
            ['Contract #:', @lading.contract_number],
            ['Origin:', @lading.origin],
            ['Grain Loaded:', @lading.human_grain_loaded],
            ['Scale Ticket #:', @lading.load_tick_num],
           ]

    pdf.table data, default_table_options
  end
end

pdf.draw_text "Carrier", :at => [0, 660], :style => :bold

pdf.indent(20) do
  pdf.bounding_box [0, 650], :height => 110, :width => 700 do
    data = [
            ['Firm:', @lading.carr_id],
            ['License #:', @lading.driver_license_num],
            ['Name:', @lading.driver_name],
            ['State:', @lading.driver_license_state]
           ]

    pdf.table data, default_table_options
  end
end

pdf.draw_text "Loading Weights", :at => [0, 560], :style => :bold

pdf.indent(20) do
  pdf.bounding_box [0, 550], :width => 700 do
    data = [
            ['Gross:', @lading.load_gross_weight],
            ['Tare:', @lading.load_tare_weight],
            ['Net:', @lading.load_net_weight],
            ['Bus:', @lading.load_bus_weight]
           ]

    pdf.table data, default_table_options
  end
end
