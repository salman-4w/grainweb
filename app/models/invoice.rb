class Invoice < ActiveRecord::Base
  default_scope select([:id, :form_num, :form_date, :comm_disp, :total_price,
    :bal_due, :days_due, :close_date, :cust])

  belongs_to :customer, foreign_key: :cust

  acts_as_grid

  def self.grid_mapping
    [
     {title: "Invoice Number", method: "form_num",     grid_id: nil, sortable: true, sql_column: "FormNum", summary_type: "count", summary_renderer: "totalWord"},
     {title: "Date",           method: "form_date",    grid_id: nil, sortable: true, sql_column: "FormDate", renderer: "date"},
     {title: "Commodity",      method: "comm_disp",    grid_id: nil, sortable: true, sql_column: "CommDisp"},
     {title: "Total Price",    method: "total_price",  grid_id: nil, sortable: true, sql_column: "TotalPrice", renderer: "Ext.util.Format.usMoney", summary_type: "count", summary_renderer: "remoteFullDollars"},
     {title: "Balance Due",    method: "bal_due",      grid_id: nil, sortable: true, sql_column: "BalDue", renderer: "Ext.util.Format.usMoney", summary_type: "count", summary_renderer: "remoteFullDollars"},
     {title: "Days Due",       method: "days_due",     grid_id: nil, sortable: true, sql_column: "DaysDue"},
     {title: "Close Date",     method: "close_date",   grid_id: nil, sortable: true, sql_column: "CloseDate", renderer: "date"},
     {title: "Actions",        method: "action_links", grid_id: "link_to_print_details", renderer: "link", sortable: false}
    ]
  end

  def action_links
    "invoices/#{self.id}/print"
  end
end
