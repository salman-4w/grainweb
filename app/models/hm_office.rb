class HmOffice < ActiveRecord::Base
  self.table_name = "HM.HMOffice"

  default_scope select([:id, :office_id, :office_name, :address])
end
