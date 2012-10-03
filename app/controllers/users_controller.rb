class UsersController < ApplicationController
  before_filter :authenticate_user!
  # TODO: Make finding the user a before_filter

  def show
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render "notfound"
    else

    end
  end

  def friend
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render "notfound"
    else
      current_user.send_friend_request!(@user)
      redirect_to @user
    end
  end

  def accept_friend
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render "notfound"
    else
      current_user.accept_friend!(@user)
      redirect_to @user
    end
  end

  def deny_friend
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render "notfound"
    else
      current_user.deny_friend!(@user)
      redirect_to @user
    end
  end
end
