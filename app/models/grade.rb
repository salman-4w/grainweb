class Grade < ActiveRecord::Base
  default_scope select([:id, :grade_id])
end
