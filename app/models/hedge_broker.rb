class HedgeBroker < ActiveRecord::Base
  default_scope select([:id, :broker_id])
end
