class TransportationType < ActiveRecord::Base
  default_scope select([:id, :name])
end
