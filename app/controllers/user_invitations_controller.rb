class UserInvitationsController < ApplicationController
  allow_unauthenticated_access only: %i[edit update]
  skip_before_action :require_admin, only: %i[edit update]
  before_action :set_user_by_token, only: %i[edit update]

  def new
    @user = User.new(role: "admin")
    respond_to do |format|
      format.html
      format.json { render json: { html: render_to_string("user_invitations/new", layout: false, formats: :html) } }
    end
  end

  def create
    @user = current_user.invite_user(params.require(:user).permit(:email_address)[:email_address])

    if @user.persisted? && @user.errors.none?
      flash[:success] = t("user_invitations.sent", email: @user.escape_value(:email_address))
      redirect_back fallback_location: account_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(params.require(:user).permit(:password, :password_confirmation).merge(invited_at: nil))
      start_new_session_for(@user)

      flash[:success] = t("user_invitations.confirmed")
      redirect_to root_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user_by_token
    @user = User.find_by_token_for!(:invitation, params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to login_path, alert: t("user_invitations.invalid_token")
  end
end
