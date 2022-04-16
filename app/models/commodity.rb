class Commodity < ActiveRecord::Base
  default_scope select([:id, :comm_name, :comm_id, :comm_disp])

  scope :for_select, select([:id, :comm_name, :comm_id]).where('DisplayOnWeb = 1').order('CommName ASC')
end
