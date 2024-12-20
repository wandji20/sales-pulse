class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  before_action :require_admin
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  private

  def require_admin
    if current_user && !current_user.confirmed
      return redirect_to login_path, notice: t("user_invitations.unconfirmed_message")
    end

    head :unauthorized unless current_user&.admin?
  end
end
