class Ticket < ActiveRecord::Base
  default_scope select([:id, :amount, :reverse_date, :o_tick_num, :tick_num,
    :net_units, :lading, :carr, :comm])

  belongs_to :lading
  belongs_to :carr, class_name: "Customer"
  belongs_to :commodity, foreign_key: :comm

  has_many :discounts, class_name: "TicketDisc", foreign_key: :ticket

  def carrier_id
    carr.cust_id rescue NoMethodError "UNKNOWN"
  end

  def lading_num
    lading.lading_num rescue NoMethodError ""
  end

  def discount_value(discount_short_name)
    discount = discounts.to_ary.find { |disc| disc.disc_type.short_name == discount_short_name }
    discount ? discount.measure : 0.00
  end
end
