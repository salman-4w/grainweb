class Booking < ActiveRecord::Base
  default_scope select([:id, :book_date, :ladings, :loads, :remaining_loads,
    :o_cont, :d_cont, :deleted, :initials])

  belongs_to :initials, class_name: "Employee"

  acts_as_grid

  def self.grid_mapping
    [
     { title: 'Date',     method: 'book_date',       grid_id: nil,        sortable: true, sql_column: 'BookDate', renderer: 'date' },
     { title: 'Employee', method: 'initials.emp_id', grid_id: 'employee', sortable: true, sql_column: 'Initials->EmpId' },
     { title: 'Ladings',  method: 'ladings',         grid_id: nil,        sortable: true, sql_column: 'Ladings' },
     { title: 'Loads',    method: 'loads',           grid_id: nil,        sortable: true, sql_column: 'Loads' },
     { title: 'Remaining Loads', method: 'remaining_loads', grid_id: nil, sortable: true, sql_column: 'RemainingLoads' }
    ]
  end
end
