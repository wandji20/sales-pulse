module Notifications
  class Report < Notification
    enum :message_type, NotificationTypes::REPORT

    def message
      case message_type.to_sym
      when :end_of_day
        # To do
        # Add link to dashboard report for notidation created_at date
        ready_link = link(I18n.t("notifications.ready"), "# ")

        I18n.t("notifications.#{message_type}_html", date: I18n.l(created_at, format: user.date_format), ready_link:)
      else
        raise "Unknow message_type"
      end
    end
  end
end
