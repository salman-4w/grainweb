class Contract::BookingsController < Contract::BaseController
  grid association: "@contract.bookings", class_name: "Booking"
end
