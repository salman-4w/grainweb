class Contract::AmendmentsController < Contract::BaseController
  grid association: "@contract.amendments", class_name: "ContAmend"
end
