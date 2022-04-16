pdf.font 'Courier'
pdf.font_size = 14

pdf.text @report.title, :style => :bold, :size => 14, :align => :center

pdf.table @report.table[:data],
          :headers => @report.table[:headers],
          :align => :left,
          :border_style => :grid,
          :border_width => 0.5,
          :font_size => 8,
          :horizontal_padding => 2,
          :vertical_padding => 2,
          :position => :center
