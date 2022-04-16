class ContAmend < ActiveRecord::Base
  default_scope select([:id, :cust_last_name, :comments, :version, :amend_date])

  acts_as_grid

  # TODO: remove me
  def unknown
    '????'
  end

  def self.grid_mapping
    [
     { title: 'Created By', method: 'cust_last_name', grid_id: nil, sortable: true, sql_column: 'CustLastName' },
     { title: 'Comments', method: 'comments', grid_id: nil, sortable: true, sql_column: 'Comments' },
     { title: 'Version', method: 'version', grid_id: nil, sortable: true, sql_column: 'Version' },
     { title: 'Amend Date', method: 'amend_date', grid_id: nil, sortable: true, sql_column: 'AmendDate', renderer: 'time' },
     { title: 'Section Changed', method: 'unknown', sortable: false },
     { title: 'New Value', method: 'unknown', sortable: false },
    ]
  end
end
