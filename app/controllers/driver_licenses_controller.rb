class DriverLicensesController < ApplicationController
  before_filter :login_required
  layout nil
  
  def search
    @lading = PendingLading.select("DriverName, DriverLicenseState").where(driver_license_num: params[:id]).first
    if @lading.nil? 
      render text: 'Not found', status: :not_found
    else
      render json: @lading.attributes.to_json
    end
  end
end
