class SessionsController < ApplicationController
  protect_from_forgery

  def create
    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

    unless @user.nil?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => request.env["omniauth.auth"].provider.capitalize
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.user_data"] = {
        provider: request.env["omniauth.auth"].provider,
        name: request.env["omniauth.auth"].extra.raw_info.name,
        username: request.env["omniauth.auth"].info.nickname,
        uid: request.env["omniauth.auth"].uid,
        email: request.env["omniauth.auth"].info.email,
        token: request.env["omniauth.auth"].credentials.token
      }

      redirect_to new_user_registration_url
    end
  end
end