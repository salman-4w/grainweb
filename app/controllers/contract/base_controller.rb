# shared functionality for contract/*_controllers
class Contract::BaseController < ApplicationController
  before_filter :login_required
  before_filter :customer_required
  before_filter :find_contract

  layout nil

  # list is used instead of index because index renders the json for the grid
  # see extjs/lib/grid.rb
  def list
    render
  end

  private

  def find_contract
    @contract = current_customer.contracts.find(params[:contract_id])
  end
end
