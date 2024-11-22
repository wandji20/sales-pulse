class Notification < ApplicationRecord
  include Rails.application.routes.url_helpers

  # Enums
  enum :delivery_type, { in_app: 0, external: 1, both: 2 }

  # Associations
  belongs_to :user
  belongs_to :subjectable, polymorphic: true, optional: true

  def message
    raise "Not implemented"
  end

  private

  def link(name, url, opts = {})
    ActionController::Base.helpers.link_to(
      name,
      url,
      { class: "link", 'data-turbo-frame': "_top", **opts }
    )
  end
end
