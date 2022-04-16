class UnitType < ActiveRecord::Base
  default_scope select([:id, :short_name, :long_name])
end
