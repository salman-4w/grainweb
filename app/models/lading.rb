class Lading < ActiveRecord::Base
  default_scope select([:id, :lading_num])
end
