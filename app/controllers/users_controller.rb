class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  before_action :require_admin, only: %i[index]

  def index
  end

  def create
    @user = User.new(user_params)
    if @user.save
      start_new_session_for(@user)
      redirect_to products_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @user = User.new
  end

  def edit
  end

  def update
  end

  def destroy
    head :unthorized unless current_user.is_admin
  end

  private

  def require_admin
    head :unathorized unless current_user.admin?
  end

  def user_params
    params.require(:user).permit(
      :full_name, :email_address, :password, :password_confirmation, :avatar)
  end
end
