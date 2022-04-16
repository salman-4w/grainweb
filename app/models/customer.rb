class Customer < ActiveRecord::Base
  default_scope select([:id, :cust_id, :freight_cust, :grain_cust, :company,
    :full_name, :contract_name, :hm_facility, :bill, :ship, :check_addr,
    :contract, :prod_cust, :ts])

  has_many :contracts, order: "ContDate DESC", foreign_key: :cust
  has_many :invoices, order: "DaysDue DESC", foreign_key: :cust
  has_many :pending_ladings, foreign_key: :orig
  has_many :checks, class_name: "GrnCheck", foreign_key: :cust
  has_many :holdings, class_name: "TicketApp", foreign_key: :customer, conditions: "Settled IS NULL"

  def date_created
    @date_created ||= ts.create_date.to_date
  end

  def addresses
    @addresses ||= [
      { type: 'Invoice',  value: bill },
      { type: 'Check',    value: check_addr },
      { type: 'Shipping', value: ship },
      { type: 'Contract', value: contract }
    ]
  end

  def to_param
    self.cust_id.to_s
  end

  def freight?
    freight_cust && freight_cust == 1
  end

  def human_freight
    @human_freight ||= freight? ? 'Y' : 'N'
  end

  def grain?
    grain_cust && grain_cust == 1
  end

  def human_grain
    @human_grain ||= grain? ? 'Y' : 'N'
  end

  def producer?
    !!prod_cust
  end

  def can_view_ladings?
    @can_view_ladings ||= hm_facility
  end

  def can_view_contracts?
    @can_view_contracts ||= !contracts.without_deferred.count.zero?
  end

  def can_view_deferred_contracts?
    @can_view_deferred_contracts ||= !contracts.deferred.count.zero?
  end

  def can_view_invoices?
    @can_view_invoices ||= !invoices.count.zero?
  end

  def can_view_checks?
    @can_view_checks ||= !checks.count.zero?
  end

  def can_view_holdings?
    @can_view_holdings ||= !holdings.count.zero?
  end
end
