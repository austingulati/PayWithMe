class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_is_admin

  def index
    @users_count = User.count
    @recent_users = User.where(stub: false).order('created_at DESC').limit(10)

    @events_count = Event.count
    @recent_events = Event.find(:all, order: 'created_at DESC', limit: 10)

    @groups_count = Group.count
    @recent_groups = Group.find(:all, order: 'created_at DESC', limit: 10)
  end

  def users
    @users = User.paginate(page: params[:page], order: 'created_at DESC')
  end

  def events
    @events = Event.paginate(page: params[:page], order: 'created_at DESC', include: [:payment_methods, :organizer])
  end

  def groups
    @groups = Group.paginate(page: params[:page], order: 'created_at DESC', include: [:group_users, :organizer])
  end

private
  def user_is_admin
    redirect_to root_path unless current_user.admin?
  end
end