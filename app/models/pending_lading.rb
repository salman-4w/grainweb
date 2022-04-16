class PendingLading < ActiveRecord::Base
  default_scope select([:id, :lading_num, :lading_date, :load_tick_num, :draft,
    :deleted, :carr_id, :tractor_license_num, :trailer_license_num,
    :driver_license_num, :driver_name, :driver_license_state,
    :load_gross_weight, :load_tare_weight, :load_net_weight, :load_bus_weight,
    :orig, :o_cont, :comm])

  attr_writer :contract_number, :grain_loaded

  belongs_to :shipper_customer, class_name: "Customer", foreign_key: :orig
  belongs_to :contract, foreign_key: :o_cont
  belongs_to :commodity, foreign_key: :comm

  validates_presence_of :lading_date
  validates_presence_of :shipper_customer

  with_options if: Proc.new { |obj| !obj.draft } do |this|
    this.validates_presence_of :grain_loaded, unless: Proc.new { |obj| obj.commodity }
    this.validates_presence_of :commodity
  end

  validates_numericality_of :load_gross_weight, :load_tare_weight,
                            :load_net_weight, :load_bus_weight,
                            greater_than_or_equal_to: 0, allow_blank: true

  before_validation :assign_associations

  before_create :generate_lading_num

  acts_as_grid

  def origin
    @origin ||= if contract && shipper_customer
      contract.fob? ? contract.location.to_s : shipper_customer.ship.to_s
    else
      nil
    end
  end

  def shipper
    @shipper ||= shipper_customer.try(:cust_id)
  end

  def contract_number
    @contract_number ||= contract.try(:cont_id)
  end

  def grain_loaded
    @grain_loaded ||= commodity.try(:id)
  end

  def human_grain_loaded
    @human_grain_loaded ||= commodity.try(:comm_name)
  end

  def human_status
    @human_status ||= draft ? 'Draft' : 'Pending'
  end

  def action_links
    if draft
      "/customers/#{self.shipper_customer.cust_id}/ladings/#{self.id}/edit"
    else
      "/customers/#{self.shipper_customer.cust_id}/ladings/#{self.id}/print"
    end
  end

  class << self
    def default(shipper_customer = nil)
      lading = self.new
      lading.lading_date = Date.today
      lading.draft = true
      lading.shipper_customer ||= shipper_customer
      lading
    end

    def grid_mapping
      [
       { title: 'Lading Num', method: 'lading_num', grid_id: nil, sortable: true, sql_column: 'LadingNum' },
       { title: 'Status', method: 'human_status', grid_id: nil, sortable: true, sql_column: 'Draft' },
       { title: 'Date', method: 'lading_date', grid_id: nil, sortable: true, sql_column: 'LadingDate', renderer: 'date' },
       { title: 'Contract #', method: 'contract_number', grid_id: nil, sortable: true, sql_column: 'OCont->ContID' },
       { title: 'Grain Loaded', method: 'human_grain_loaded', grid_id: nil, sortable: true, sql_column: 'Comm->CommName' },
       { title: 'Scale Ticket #', method: 'load_tick_num', grid_id: nil, sortable: true, sql_column: 'LoadTickNum' },
       { title: 'Actions', method: 'action_links', grid_id: 'actions', renderer: 'link', sortable: false }
      ]
    end
  end

  private
  def assign_associations
    self.contract = shipper_customer.contracts.find_by_cont_id(@contract_number) if !@contract_number.blank? && shipper_customer
    self.commodity = Commodity.find(@grain_loaded) unless @grain_loaded.blank?
  end

  def generate_lading_num
    initial_value = 600001
    max = self.class.where("{fn convert(LadingNum,  SQL_INTEGER)} >= #{initial_value}").maximum('LadingNum').to_i
    self.lading_num = max < initial_value ? initial_value : max + 1
  end
end
