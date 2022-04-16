class Employee < ActiveRecord::Base
  default_scope select([:id, :emp_id, :first_last_name])
end
