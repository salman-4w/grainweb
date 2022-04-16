class Contract::TicketsController < Contract::BaseController
  grid association: "@contract.ticket_apps", class_name: "TicketApp"
end
