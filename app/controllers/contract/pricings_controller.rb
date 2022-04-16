class Contract::PricingsController < Contract::BaseController
  grid association: "@contract.pricings", class_name: "ContPricing"
end
