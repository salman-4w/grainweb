class SessionsController < ApplicationController
  def new
    render
  end

  def create
    logout_keeping_session!
    user = WebUser.authenticate(params[:username], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user

      # new_cookie_flag = (params[:remember_me] == "1")
      # handle_remember_cookie! new_cookie_flag

      # check if user logged in first time
      if user.is_first_login
        user.is_first_login = false
        user.save
        redirect_to profile_url, notice: "Welcome. Please customize your username and password at this time."
      else
        redirect_back_or_default('/')
      end
    else
      note_failed_signin
      @username = params[:username]
      render action: "new"
    end
  end

  def destroy
    logout_killing_session!
    redirect_back_or_default("/")
  end

  protected
  # Track failed login attempts
  def note_failed_signin
    flash.now[:error] = "Invalid username or password."
    logger.warn "Failed log in for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
