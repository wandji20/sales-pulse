module ApplicationHelper
  def avatar_image
    return render "shared/svgs/person", svg_class: "rounded-full" if true

    image_tag("https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80", class: "h-6 w-6 rounded-full")
  end

  def nav_user_links
    return render "navbar/signed_in_links" if true

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
    case type
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
    case type
    when "error", "alert"
      "shared/svgs/exclamation_triangle"
    when "success"
      "shared/svgs/check_circle"
    else
      "shared/svgs/information_circle"
    end
  end
end
