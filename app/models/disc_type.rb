class DiscType < ActiveRecord::Base
  default_scope select([:id, :short_name])
end
