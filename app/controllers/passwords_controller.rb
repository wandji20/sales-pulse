class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  before_action :verify_invitation_token, only: %i[ edit update ]

  def new; end

  def create
    if user = User.find_by(email_address: params[:email_address])
      if user.invited_at.present?
        redirect_to root_path, alert: t("passwords.invitation_sent")
        return
      end

      PasswordsMailer.reset(user).deliver_later
      redirect_to login_url, notice: t("passwords.instruction_sent")
    else
      redirect_to root_path, alert: t("passwords.incorrect_email")
    end
  end

  def edit; end

  def update
    if @user.update(password_params)
      redirect_to login_url, notice: t("passwords.reset_successful")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_url, alert: t("password.invalid_token")
    end

    def password_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def verify_invitation_token
      if @user.invited_at.present?
        redirect_to root_path, alert: t("passwords.invitation_sent")
      end
    end
end
