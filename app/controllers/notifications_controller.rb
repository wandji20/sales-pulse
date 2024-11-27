class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications
                                 .includes([{subjectable: :product}])
                                 .order(created_at: :desc)
  end
end
