class WebUserCustomerItem < ActiveRecord::Base
  default_scope select([:id, :web_user, :cust_id])

  belongs_to :user, class_name: "WebUser", foreign_key: :web_user
  belongs_to :customer, foreign_key: :cust_id
end
