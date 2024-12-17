class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  before_action :require_admin
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  private

  def require_admin
    head :unauthorized unless current_user&.admin?
  end
end
