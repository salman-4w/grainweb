class ContPricing < ActiveRecord::Base
  default_scope select([:id, :pricing_id, :qty, :basis, :fut_used, :price,
    :fut_month, :price_date, :un_settle, :xcfo, :emp, :broker])

  acts_as_grid

  belongs_to :emp, class_name: "Employee"
  belongs_to :broker, class_name: "HedgeBroker"

  has_many :ticket_apps, foreign_key: :cont

  class << self
    def grid_mapping
      [
       { title: 'Quantity', method: 'qty', grid_id: nil, sortable: true, sql_column: 'Qty', renderer: 'quantity' },
       { title: 'Basis', method: 'basis', grid_id: nil, sortable: true, sql_column: 'Basis', renderer: 'Ext.util.Format.usMoney' },
       { title: 'Futures', method: 'fut_used', grid_id: nil, sortable: true, sql_column: 'FutUsed', renderer: 'Ext.util.Format.usMoney' },
       { title: 'Price', method: 'price', grid_id: nil, sortable: true, sql_column: 'Price', renderer: 'Ext.util.Format.usMoney' },
       { title: 'FutMonth', method: 'fut_month', grid_id: nil, sortable: true, sql_column: 'FutMonth', renderer: 'date' },
       { title: 'PriceDate', method: 'price_date', grid_id: nil, sortable: true, sql_column: 'PriceDate', renderer: 'date' },
       { title: 'Merchant', method: 'emp.emp_id', grid_id: 'merchant', sortable: true, sql_column: 'Emp->EmpId' },
       { title: 'UnsettleQty', method: 'un_settle', grid_id: nil, sortable: true, sql_column: 'UnSettle', renderer: 'quantity' },
       { title: 'XCFO', method: 'xcfo', grid_id: nil, sortable: true, sql_column: 'XCFO' },
       { title: 'Broker', method: 'broker.broker_id', grid_id: 'broker', sortable: true, sql_column: 'Broker->BrokerId' }
      ]
    end
  end
end
