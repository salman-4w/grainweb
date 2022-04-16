class Contract < ActiveRecord::Base
  default_scope select([:id, :cont_id, :qty, :w_loc_id, :g_loc_id, :pur_sale,
    :fob_delv, :cont_date, :end_date, :cont_price, :basis, :fut_month,
    :fut_used, :price_type, :cust_last_name, :deferred_price, :deferred_date,
    :deferred_rate, :deferred_interest, :ship_start, :ship_end, :un_settle,
    :unprocessed, :comm, :grade, :unit_id, :loc, :cust, :emp, :hm_office,
    :transportation_type, :po_number])

  extend ActiveSupport::Memoizable
  include ActionView::Helpers::NumberHelper
  include ContractsHelper

  def self.deferred
    where price_type: "DP"
  end

  def self.without_deferred
    where "PriceType != 'DP'"
  end

  # See: http://www.codeproject.com/dotnet/Zip_code_radius_search.asp
  # Degrees to Radians converstion factor (take inverse for opposite)
  DEGREES_TO_RADIANS = (Math::PI/180).freeze

  MILES_PER_LATITUDE_DEGREE = (69.1).freeze
  EARTH_RADIUS_IN_MILES = 3963
  LATITUDE_DEGREES = (EARTH_RADIUS_IN_MILES / MILES_PER_LATITUDE_DEGREE).freeze

  DEFAULT_RADIUS = 30

  PRICE_TYPES = {
    p: 'Priced',
    b: 'Basis',
    h: 'Hedge To Arrive',
    d: 'NPE',
    dp: 'Deferred Pay'
  }.freeze

  PURCHASE_SALE_TYPES = {
    p: 'Purchase',
    s: 'Sale'
  }.freeze

  FOB_DELIVERED_TYPES = {
    f: 'FOB',
    d: 'Delivered'
  }.freeze

  WEIGHTS_GRADES_TYPES = {
    o: 'Origin',
    d: 'Destination',
    :'1' => '1st Official'
  }.freeze

  MONTH_CODES = [
    'F', # January
    'G', # February
    'H', # March
    'J', # April
    'K', # May
    'M', # June
    'N', # July
    'Q', # August
    'U', # September
    'V', # October
    'X', # November
    'Z' # December
  ].freeze

  belongs_to :commodity, foreign_key: :comm
  belongs_to :grade
  belongs_to :unit_type, foreign_key: :unit_id
  belongs_to :location, foreign_key: :loc
  belongs_to :customer, foreign_key: :cust
  belongs_to :employee, foreign_key: :emp
  belongs_to :hm_office
  belongs_to :transportation_type

  has_many :pricings, class_name: "ContPricing", foreign_key: :contract
  has_many :amendments, class_name: "ContAmend", foreign_key: :contract
  has_many :ticket_apps, foreign_key: "Cont->Contract"

  acts_as_grid

  # return array with mappings for grid
  # where each element is an array with following format
  # title, method, grid id (if nill 'method' will be used), sortable (true or false), sort column
  def self.grid_mapping
    [
     # visible by default
     {title: "Contract",     method: "cont_id",             grid_id: nil,              sortable: true, sql_column: "ContId", summary_type: "count", summary_renderer: "totalWord"},
     {title: "Commodity",    method: "commodity.comm_name", grid_id: "commodity_name", sortable: true, sql_column: "Comm->CommName"},
     {title: "Start Date",   method: "ship_start",          grid_id: nil,              sortable: true, sql_column: "ShipStart", renderer: "date"},
     {title: "Quantity",     method: "qty",                 grid_id: nil,              sortable: true, sql_column: "Qty", renderer: "quantity", summary_type: "count", summary_renderer: "remoteFullTotal"},
     {title: "Price Type",   method: "human_price_type",    grid_id: nil,              sortable: true, sql_column: "PriceType"},
     {title: "Price",        method: "price",               grid_id: nil,              sortable: true, sql_column: "ContPrice", renderer: "Ext.util.Format.usMoney"},
     {title: "UnPriced Qty", method: "un_priced_qty",       grid_id: nil,              sortable: true, sql_column: "UnPricedQty", renderer: "quantity"},
     {title: "UnSettle Qty", method: "un_settle",           grid_id: nil,              sortable: true, sql_column: "UnSettle", renderer: "quantity"},
     # hidden by default
     {title: "Contract Date", method: "cont_date",           grid_id: nil,        sortable: true, sql_column: "ContDate", hidden: true, renderer: "date"},
     {title: "FOB/Delivered", method: "human_fob_delivered", grid_id: nil,        sortable: true, sql_column: "FOBDelv", hidden: true},
     {title: "Location",      method: "location.to_s",       grid_id: "location", sortable: true, sql_column: "Loc->CitySt", hidden: true},
     {title: "Purchase/Sale", method: "human_purchase_sale", grid_id: nil,        sortable: true, sql_column: "PurSale", hidden: true}
    ]
  end

  def self.grid_mapping_for_deferred_contracts
    unsettle_qty_column_index = 7
    grid_mapping.tap do |mapping|
      mapping[unsettle_qty_column_index] = {
        title: 'Unprocessed', method: 'unprocessed', grid_id: nil, sortable: true, sql_column: 'Unprocessed', renderer: 'quantity'
      }
    end
  end

  def bookings
    Booking.where('(OCont = :id or DCont = :id) AND (Deleted = 0 OR Deleted IS NULL)', { id: id })
  end
  memoize :bookings

  def closed?
    !(un_settle > 0)
  end

  def human_fob_delivered
    @human_fob_delivered ||= FOB_DELIVERED_TYPES[fob_delivered]
  end

  def fob_delivered
    @fob_delivered ||= self['fob_delv'].downcase.to_sym
  end

  def commodity_name
    @commodity_name ||= commodity.comm_name
  end

  def fob?
    :f == fob_delivered
  end

  def human_purchase_sale
    @human_purchase_sale ||= PURCHASE_SALE_TYPES[purchase_sale]
  end

  def purchase_sale
    @purchase_sale ||= self['pur_sale'].downcase.to_sym
  end

  def purchased?
    :p == purchase_sale
  end

  def sold?
    :s == purchase_sale
  end

  # FIXME: do we need this method?
  def price_type_for_view
    @price_type_for_view ||= "#{human_price_type} #{link_to_pricing self}"
  end

  def human_price_type
    @human_price_type ||= PRICE_TYPES[price_type]
  end

  def price_type
    @price_type ||= self['price_type'].downcase.to_sym
  end

  def merchant_name
    @merchant ||= employee.first_last_name
  end

  def customer_name
    @customer_name ||= customer.full_name
  end

  def deferred_pay?
    :dp == price_type
  end

  def human_weights
    @human_weights ||= WEIGHTS_GRADES_TYPES[weights_type]
  end

  def weights_type
    @weights_type ||= self['w_loc_id'].downcase.to_sym
  end

  def human_grades
    @human_grades ||= WEIGHTS_GRADES_TYPES[grades_type]
  end

  def grades_type
    @grades_type ||= self['g_loc_id'].downcase.to_sym
  end

  def price
    @price ||= case price_type
      when :p, :h then self.cont_price
      when :b then self.basis
      when :d, :dp then nil
      else 'NOT IMPL'
    end
  end

  def future_month_code
    return nil unless self.fut_month
    @future_month_code ||= MONTH_CODES[self.fut_month.month - 1]
  end

  def future_month_code_and_year
    return "" unless self.fut_month
    @future_month_code_and_year ||= "#{future_month_code}#{self.fut_month.strftime('%y')}"
  end

  def report_basis
    @report_basis ||= case price_type
      when :b then "#{number_to_currency self.basis} #{self.future_month_code}"
      when :p then "#{number_to_currency self.cont_price} #{self.unit_type.short_name}"
      when :h then "#{number_to_currency self.fut_used} #{self.future_month_code}"
      when :d then "Pricing Deferred"
      when :dp
        result = "#{number_to_currency self.deferred_price} #{self.unit_type.short_name}"
        result << " Payment due "
        result << (self.deferred_date.blank? ? 'upon demand' : self.deferred_date.to_s(:report))
        result << "\nCharges: Less grain tax and any discounts that apply."
        result << "\nPlus premium (#{self.deferred_rate}%)#{number_to_currency self.deferred_interest}"
        result
    end
  end

  def daily_deferred_rate
    @daily_deferred_rate ||= (deferred_rate / 100 / 365)
  end

  def defer_days
    @defer_days ||= (deferred_date - cont_date).to_i
  end

  def defer_days_till_today
    @defer_days_till_today ||= (Date.today - cont_date).to_i
  end
end
