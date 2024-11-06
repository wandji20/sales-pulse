class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]

  def new; end

  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to login_url, notice: t("users.password.instructions_sent")
  end

  def edit; end

  def update
    if @user.update(password_params)
      redirect_to login_url, notice: t("users.password.rest_successful")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_url, alert: t("users.password.invalid_token")
    end

    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
