class UiStateController < ApplicationController
  skip_before_filter :verify_authenticity_token

  before_filter :login_required

  def show
    ui_state_json = current_user.ui_state || {}.to_json
    render json: ui_state_json, layout: false
  end

  def update
    # TODO: move some of this to model callbacks
    state = current_user.ui_state_object
    state_for_key = state[params[:name]]

    new_state_for_key = json_to_object(params[:value])

    state[params[:name]] = new_state_for_key unless state_for_key == new_state_for_key

    current_user.ui_state = state.to_json
    current_user.save

    render nothing: true
  end

  def destroy
    current_user.ui_state = ''
    current_user.save

    render nothing: true
  end

  private
  def json_to_object(string)
    return {} if string.blank?

    begin
      ActiveSupport::JSON.decode(string)
    rescue ActiveSupport::JSON::ParseError
      {}
    end
  end
end
