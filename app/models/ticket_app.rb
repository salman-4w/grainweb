class TicketApp < ActiveRecord::Base
  APPLY_TYPES = {
    c: 'Contract',
    s: 'Spot',
    t: 'Storage',
    o: 'Overfill',
    h: 'Held',
    u: 'UnPriced',
    p: 'Out of storage (spot)',
    n: 'Out of storage (contract)',
    w: 'WH Receipt',
    f: 'Off-site',
    ts: 'Terminal Storage',
    pd: 'Pending'
  }.freeze

  default_scope select([:id, :tick_num, :net_units, :settled, :price,
    :gross_units, :gross_dollars, :disc_dollars, :entered, :tax_amount,
    :gross_lbs, :net_lbs, :storage, :net_dollars, :apply_type, :dlv_date,
    :form_num, :misc_remarks, :pur_sale, :lading, :ticket])

  belongs_to :ticket
  belongs_to :cont, class_name: "ContPricing"
  belongs_to :grn_check, foreign_key: :grn_check
  belongs_to :invoice
  belongs_to :defer_cont, class_name: "Contract"

  acts_as_grid

  def human_apply_type
    @human_apply_type ||= APPLY_TYPES[apply_type]
  end

  def apply_type
    @apply_type ||= self['apply_type'].downcase.to_sym
  end

  def overfill_apply_type?
    :o == apply_type
  end

  def form_date
    case
      when grn_check && grn_check.form_date then grn_check.form_date
      when invoice && invoice.form_date then invoice.form_date
      else nil
    end
  end

  def defer_premium
    unless @defer_premium
      @defer_premium = defer_cont ? (net_dollars * defer_cont.daily_deferred_rate * defer_cont.defer_days) : 0.00
    end

    @defer_premium
  end

  def payable_dollars
    @payable_dollars ||= net_dollars + defer_premium
  end

  def payable_dollars_today
    unless @payable_dollars_today
      addition = defer_cont ? (net_dollars * defer_cont.daily_deferred_rate * defer_cont.defer_days_till_today) : 0.00
      @payable_dollars_today = net_dollars + addition
    end
    @payable_dollars_today
  end

  class << self
    # default grid mapping
    def grid_mapping
      [
       {title: "Ticket #", method: 'tick_num', grid_id: nil, sortable: true, sql_column: 'TickNum' },
       {title: "Lading", method: 'ticket.lading.lading_num', grid_id: 'lading', sortable: true, sql_column: 'Ticket->Lading->LadingNum' },
       {title: "Apply Units", method: 'net_units', grid_id: nil, sortable: true, sql_column: 'NetUnits', renderer: 'quantity' },
       {title: "Ticket Amount $", method: 'ticket.amount', grid_id: 'ticket_amount', sortable: true, sql_column: 'Ticket->Amount' },
       {title: "Settled", method: 'settled', grid_id: nil, sortable: true, sql_column: 'Settled', renderer: 'date' },
       {title: "Price", method: 'price', grid_id: nil, sortable: true, sql_column: 'Price', renderer: 'Ext.util.Format.usMoney' },
       {title: "Gross Units", method: 'gross_units', grid_id: nil, sortable: true, sql_column: 'GrossUnits', renderer: 'quantity' },
       {title: "Gross Dollars", method: 'gross_dollars', grid_id: nil, sortable: true, sql_column: 'GrossDollars', renderer: 'Ext.util.Format.usMoney' },
       {title: "Disc Dollars", method: 'disc_dollars', grid_id: nil, sortable: true, sql_column: 'DiscDollars', renderer: 'Ext.util.Format.usMoney' },
       {title: "Contract Pricing ID", method: 'cont.pricing_id', grid_id: 'cont_pricing_id', sortable: true, sql_column: 'Cont->PricingId' },
       {title: "Entered", method: 'entered', grid_id: nil, sortable: true, sql_column: 'Entered', renderer: 'date' },
       {title: "Reverse Date", method: 'ticket.reverse_date', grid_id: 'reverse_date', sortable: true, sql_column: 'Ticket->ReverseDate' },
       {title: "Tax Amount", method: 'tax_amount', grid_id: nil, sortable: true, sql_column: 'TaxAmount', renderer: 'Ext.util.Format.usMoney' }
      ]
    end

    # grid shown on customer_holdings page
    def grid_mapping_for_customer_holdings
      [
       {title: "Scale Ticket", method: 'tick_num', grid_id: nil, sortable: true, sql_column: 'TickNum', summary_type: 'count', summary_renderer: 'totalWord' },
       {title: "Delivery Date", method: 'dlv_date', grid_id: nil, sortable: true, sql_column: 'DlvDate', renderer: 'date' },
       {title: "Commodity", method: 'ticket.commodity.comm_name', grid_id: 'commodity_name', sortable: true, sql_column: 'Ticket->Comm->CommName' },
       {title: "Type", method: 'human_apply_type', grid_id: nil, sortable: true, sql_column: 'ApplyType' },
       {title: "Gross Bushels", method: 'gross_units', grid_id: nil, sortable: true, sql_column: 'GrossUnits', renderer: 'quantity', summary_type: 'count', summary_renderer: 'remoteFullTotal' },
       {title: "Net Bushels", method: 'net_units', grid_id: nil, sortable: true, sql_column: 'NetUnits', renderer: 'quantity', summary_type: 'count', summary_renderer: 'remoteFullTotal' }
      ]
    end
  end
end
