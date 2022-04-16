class ProfilesController < ApplicationController
  before_filter :login_required

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if update_user(@user)
      redirect_to home_url, notice: "Your profile was successfully updated."
    else
      render action: 'show'
    end
  end

  private
  def need_to_change_password?
    @need_to_change_password ||= params[:user][:new_password].present?
  end

  def need_to_change_login?
    @need_to_change_login ||= params[:user][:web_user_id].present? && current_user.web_user_id != params[:user][:web_user_id]
  end

  def update_user(user)
    if need_to_change_password?
      return false unless user.change_password(params[:user][:new_password], params[:user][:new_password_confirmation])
    end

    if need_to_change_login?
      user.web_user_id = params[:user][:web_user_id]
      return false unless user.save
    end

    return need_to_change_password? || need_to_change_login?
  end
end
