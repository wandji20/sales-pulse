module ApplicationHelper
  include Pagy::Frontend

  def escape_input(string)
    ERB::Util.html_escape(string)
  end

  def avatar_image
    return image_tag(current_user.avatar, class: "h-8 w-8 rounded-full") if current_user&.avatar&.attached?

    render "shared/svgs/person", svg_class: "rounded-full"
  end

  def nav_user_links
    return render "navbar/signed_in_links" if current_user

    render "navbar/signed_out_links"
  end

  def active_class(action, controller = nil)
    return unless action.presence == action_name
    return if controller.present? && controller != controller_name

    "active"
  end

  def displayable_flash_type?(type)
    %w[success alert error notice].include?(type)
  end

  def flash_alert_class(type)
    case type.to_s
    when "success"
      "alert-success"
    when "error"
      "alert-danger"
    when "alert"
      "alert-alert"
    else
      "alert-info"
    end
  end

  def flash_icon(type)
    case type.to_s
    when "error", "alert"
      "shared/svgs/exclamation_triangle"
    when "success"
      "shared/svgs/check_circle"
    else
      "shared/svgs/information_circle"
    end
  end
end
