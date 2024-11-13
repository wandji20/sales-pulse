module UsersHelper
  def toggle_button_state(user, keys)
    return unless keys.present?
    return "enabled" if user.settings.dig(*keys)

    "disabled"
  end
end
