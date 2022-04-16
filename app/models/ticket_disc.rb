class TicketDisc < ActiveRecord::Base
  default_scope select([:id, :disc, :measure])

  belongs_to :disc_type, foreign_key: :disc
end
