pdf.font "Courier"
pdf.font_size = 14

if current_customer
  stamp_text = "#{current_customer.company} (#{current_customer.cust_id})"

  stamp_font_size = 8

  horizontal_position = pdf.bounds.top_right.first - pdf.width_of(stamp_text, size: stamp_font_size)

  pdf.repeat :all do
    pdf.draw_text stamp_text, size: stamp_font_size, at: [horizontal_position, 900]
  end
end

pdf.text @report.title, style: :bold, size: 14, align: :center

pdf.table @report.table[:data],
          headers: @report.table[:headers],
          align: :left,
          border_style: :grid,
          border_width: 0.5,
          font_size: 8,
          horizontal_padding: 2,
          vertical_padding: 2,
          position: :center
