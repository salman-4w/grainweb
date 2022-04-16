class GrnCheck < ActiveRecord::Base
  default_scope select([:id, :form_date, :cust, :form_num, :form_date, :comm,
    :total_price, :cleared_date, :cleared_amount, :comm, :cust])

  belongs_to :commodity, foreign_key: :comm
  belongs_to :customer, foreign_key: :cust

  acts_as_grid

  def self.grid_mapping
    [
     {title: "Check Number",   method: "form_num",            grid_id: nil, sortable: true,         sql_column: "FormNum", summary_type: "count", summary_renderer: "totalWord"},
     {title: "Check Date",     method: "form_date",           grid_id: nil, sortable: true,         sql_column: "FormDate", renderer: "date"},
     {title: "Commodity",      method: "commodity.comm_name", grid_id: "commodity", sortable: true, sql_column: "Comm->CommName"},
     {title: "Total Price",    method: "total_price",         grid_id: nil, sortable: true,         sql_column: "TotalPrice", renderer: "Ext.util.Format.usMoney", summary_type: "count", summary_renderer: "remoteFullDollars"},
     {title: "Cleared Date",   method: "cleared_date",        grid_id: nil, sortable: true,         sql_column: "ClearedDate", renderer: "date"},
     {title: "Cleared Amount", method: "cleared_amount",      grid_id: nil, sortable: true,         sql_column: "ClearedAmount", renderer: "Ext.util.Format.usMoney", summary_type: "count", summary_renderer: "remoteFullDollars"},
     {title: "Actions",        method: "action_links",        grid_id: "link_to_print_details", renderer: "link", sortable: false}
    ]
  end

  def action_links
    "checks/#{self.id}/print"
  end
end
