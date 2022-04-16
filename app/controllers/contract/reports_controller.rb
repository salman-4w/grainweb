class Contract::ReportsController < Contract::BaseController
  before_filter :find_pricing, only: [:ticket_applications, :dollars]

  def pricing
    render
  end

  def amendment
    @amendment = @contract.amendments.find(params[:amendment_id]) unless params[:amendment_id].blank?
  end

  def confirmation
    render
  end

  def ticket_applications
    render
  end

  def ticket_dollars
    render
  end

  private

  def find_pricing
    @pricing = params[:pricing_id].blank? ? nil : @contract.pricings.find(params[:pricing_id])
  end
end
